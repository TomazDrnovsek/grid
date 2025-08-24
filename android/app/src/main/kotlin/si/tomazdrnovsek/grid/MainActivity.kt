package si.tomazdrnovsek.grid

import android.content.Intent
import androidx.core.net.toUri
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicLong

class MainActivity: FlutterActivity() {
    private val channelName = "com.grid/saf"
    private lateinit var methodChannel: MethodChannel
    private var pendingResult: MethodChannel.Result? = null

    // Lifecycle-bound scope to fix "delicate API" warnings
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    // Write session management for streaming operations
    private val writeSessionCounter = AtomicLong(0)
    private val activeSessions = ConcurrentHashMap<String, BufferedOutputStream>()

    companion object {
        private const val PICK_DIRECTORY_REQUEST_CODE = 42
        private const val BUFFER_SIZE = 65536 // 64KB buffer for streaming
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "pickDirectory" -> pickDirectory(result)
                "releaseUri" -> releaseUri(call.argument<String>("uri")!!, result)
                "exists" -> checkExists(
                    call.argument<String>("uri")!!,
                    call.argument<String>("relativePath")!!,
                    result
                )
                "list" -> listDirectory(
                    call.argument<String>("uri")!!,
                    call.argument<String>("relativeDir")!!,
                    result
                )
                "read" -> readFile(
                    call.argument<String>("uri")!!,
                    call.argument<String>("relativePath")!!,
                    result
                )
                "write" -> writeFile(
                    call.argument<String>("uri")!!,
                    call.argument<String>("relativePath")!!,
                    call.argument<ByteArray>("bytes")!!,
                    call.argument<Boolean>("createDirs") ?: true,
                    result
                )
                // NEW: Streaming write sessions for large files
                "beginWrite" -> beginWrite(
                    call.argument<String>("uri")!!,
                    call.argument<String>("relativePath")!!,
                    call.argument<Boolean>("createDirs") ?: true,
                    result
                )
                "writeChunk" -> writeChunk(
                    call.argument<String>("token")!!,
                    call.argument<ByteArray>("data")!!,
                    result
                )
                "endWrite" -> endWrite(
                    call.argument<String>("token")!!,
                    result
                )
                "abortWrite" -> abortWrite(
                    call.argument<String>("token")!!,
                    result
                )
                // NEW: Native copy for efficient restore
                "copyToLocalFile" -> copyToLocalFile(
                    call.argument<String>("uri")!!,
                    call.argument<String>("relativePath")!!,
                    call.argument<String>("destPath")!!,
                    result
                )
                "mkdirs" -> makeDirectories(
                    call.argument<String>("uri")!!,
                    call.argument<String>("relativeDir")!!,
                    result
                )
                "rename" -> renameFile(
                    call.argument<String>("uri")!!,
                    call.argument<String>("fromPath")!!,
                    call.argument<String>("toPath")!!,
                    result
                )
                "delete" -> deleteFile(
                    call.argument<String>("uri")!!,
                    call.argument<String>("relativePath")!!,
                    result
                )
                "getPersistedUris" -> getPersistedUris(result)
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Close all active write sessions
        activeSessions.values.forEach { stream ->
            try {
                stream.close()
            } catch (_: Exception) {
                // Ignore cleanup errors
            }
        }
        activeSessions.clear()
        ioScope.cancel()  // Prevents memory leaks
    }

    private fun pickDirectory(result: MethodChannel.Result) {
        pendingResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
        }
        startActivityForResult(intent, PICK_DIRECTORY_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == PICK_DIRECTORY_REQUEST_CODE && pendingResult != null) {
            val channelResult = pendingResult!!
            pendingResult = null

            if (resultCode == RESULT_OK && data?.data != null) {
                val uri = data.data!!
                try {
                    // CRITICAL FIX: Build flags only from the two allowed constants
                    val grantedRead =
                        if ((data.flags and Intent.FLAG_GRANT_READ_URI_PERMISSION) != 0)
                            Intent.FLAG_GRANT_READ_URI_PERMISSION else 0
                    val grantedWrite =
                        if ((data.flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION) != 0)
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION else 0
                    val takeFlags = grantedRead or grantedWrite

                    // Call without named argument (Java method)
                    contentResolver.takePersistableUriPermission(uri, takeFlags)

                    val documentFile = DocumentFile.fromTreeUri(this, uri)
                    val displayName = documentFile?.name ?: "Selected Folder"

                    channelResult.success(mapOf(
                        "uri" to uri.toString(),
                        "name" to displayName
                    ))
                } catch (e: SecurityException) {
                    channelResult.error("PERMISSION_ERROR", "Failed to persist URI permission: ${e.message}", null)
                } catch (e: Exception) {
                    channelResult.error("PICK_ERROR", "Error picking directory: ${e.message}", null)
                }
            } else {
                channelResult.success(null)
            }
        }
    }

    private fun releaseUri(uriString: String, result: MethodChannel.Result) {
        try {
            val uri = uriString.toUri()
            contentResolver.releasePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )
            result.success(true)
        } catch (e: Exception) {
            result.error("RELEASE_ERROR", e.message, null)
        }
    }

    private fun checkExists(uriString: String, relativePath: String, result: MethodChannel.Result) {
        try {
            val rootUri = uriString.toUri()
            val rootDoc = DocumentFile.fromTreeUri(this, rootUri)

            if (rootDoc == null || !rootDoc.exists()) {
                result.success(false)
                return
            }

            val targetFile = navigateToPath(rootDoc, relativePath)
            result.success(targetFile?.exists() ?: false)
        } catch (e: Exception) {
            result.error("EXISTS_ERROR", e.message, null)
        }
    }

    private fun listDirectory(uriString: String, relativeDir: String, result: MethodChannel.Result) {
        try {
            val rootUri = uriString.toUri()
            val rootDoc = DocumentFile.fromTreeUri(this, rootUri)

            if (rootDoc == null || !rootDoc.exists()) {
                result.error("NOT_FOUND", "Root directory not found", null)
                return
            }

            val targetDir = if (relativeDir.isEmpty() || relativeDir == ".") {
                rootDoc
            } else {
                navigateToPath(rootDoc, relativeDir)
            }

            if (targetDir == null || !targetDir.isDirectory) {
                result.error("NOT_DIRECTORY", "Target is not a directory", null)
                return
            }

            val entries = mutableListOf<Map<String, Any>>()
            targetDir.listFiles().forEach { file ->
                file?.let {
                    entries.add(mapOf(
                        "name" to (it.name ?: ""),
                        "type" to (if (it.isDirectory) "directory" else "file"),
                        "size" to it.length(),
                        "lastModified" to it.lastModified(),
                        "mimeType" to (it.type ?: "")
                    ))
                }
            }

            result.success(entries)
        } catch (e: Exception) {
            result.error("LIST_ERROR", e.message, null)
        }
    }

    private fun readFile(uriString: String, relativePath: String, result: MethodChannel.Result) {
        ioScope.launch {
            try {
                val rootUri = uriString.toUri()
                val rootDoc = DocumentFile.fromTreeUri(this@MainActivity, rootUri)

                if (rootDoc == null || !rootDoc.exists()) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Root directory not found", null)
                    }
                    return@launch
                }

                val targetFile = navigateToPath(rootDoc, relativePath)
                if (targetFile == null || !targetFile.isFile) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FILE", "Target is not a file", null)
                    }
                    return@launch
                }

                val inputStream = contentResolver.openInputStream(targetFile.uri)
                if (inputStream == null) {
                    withContext(Dispatchers.Main) {
                        result.error("OPEN_ERROR", "Cannot open file", null)
                    }
                    return@launch
                }

                inputStream.use { stream ->
                    val bytes = stream.readBytes()
                    withContext(Dispatchers.Main) {
                        result.success(bytes)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("READ_ERROR", e.message, null)
                }
            }
        }
    }

    // LEGACY: Keep for small files, but use streaming for large files
    private fun writeFile(
        uriString: String,
        relativePath: String,
        bytes: ByteArray,
        createDirs: Boolean,
        result: MethodChannel.Result
    ) {
        ioScope.launch {
            try {
                val rootUri = uriString.toUri()
                val rootDoc = DocumentFile.fromTreeUri(this@MainActivity, rootUri)

                if (rootDoc == null || !rootDoc.exists()) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Root directory not found", null)
                    }
                    return@launch
                }

                // Parse path components
                val pathParts = relativePath.split("/").filter { it.isNotEmpty() }
                if (pathParts.isEmpty()) {
                    withContext(Dispatchers.Main) {
                        result.error("INVALID_PATH", "Invalid relative path", null)
                    }
                    return@launch
                }

                // Navigate/create directories
                var currentDir: DocumentFile = rootDoc
                for (i in 0 until pathParts.size - 1) {
                    val dirName = pathParts[i]
                    var nextDir: DocumentFile? = currentDir.findFile(dirName)

                    if (nextDir == null && createDirs) {
                        nextDir = currentDir.createDirectory(dirName)
                    }

                    if (nextDir == null || !nextDir.isDirectory) {
                        withContext(Dispatchers.Main) {
                            result.error("DIRECTORY_ERROR", "Cannot access directory: $dirName", null)
                        }
                        return@launch
                    }

                    currentDir = nextDir
                }

                // Create or get target file
                val fileName = pathParts.last()
                var targetFile: DocumentFile? = currentDir.findFile(fileName)

                if (targetFile == null) {
                    // Determine MIME type from extension
                    val mimeType = when {
                        fileName.endsWith(".jpg", true) || fileName.endsWith(".jpeg", true) -> "image/jpeg"
                        fileName.endsWith(".png", true) -> "image/png"
                        fileName.endsWith(".webp", true) -> "image/webp"
                        fileName.endsWith(".json", true) -> "application/json"
                        fileName.endsWith(".txt", true) -> "text/plain"
                        else -> "application/octet-stream"
                    }

                    targetFile = currentDir.createFile(mimeType, fileName)
                    if (targetFile == null) {
                        withContext(Dispatchers.Main) {
                            result.error("CREATE_FILE_ERROR", "Cannot create file: $fileName", null)
                        }
                        return@launch
                    }
                }

                // CRITICAL FIX: Use "wt" for truncate mode on small files (legacy behavior)
                val outputStream = contentResolver.openOutputStream(targetFile.uri, "wt")
                if (outputStream == null) {
                    withContext(Dispatchers.Main) {
                        result.error("OPEN_OUTPUT_ERROR", "Cannot open file for writing", null)
                    }
                    return@launch
                }

                outputStream.use { stream ->
                    stream.write(bytes)
                    stream.flush()
                }

                withContext(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("WRITE_ERROR", e.message, null)
                }
            }
        }
    }

    // NEW: Begin streaming write session with append mode
    private fun beginWrite(
        uriString: String,
        relativePath: String,
        createDirs: Boolean,
        result: MethodChannel.Result
    ) {
        ioScope.launch {
            try {
                val rootUri = uriString.toUri()
                val rootDoc = DocumentFile.fromTreeUri(this@MainActivity, rootUri)

                if (rootDoc == null || !rootDoc.exists()) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Root directory not found", null)
                    }
                    return@launch
                }

                // Parse path components
                val pathParts = relativePath.split("/").filter { it.isNotEmpty() }
                if (pathParts.isEmpty()) {
                    withContext(Dispatchers.Main) {
                        result.error("INVALID_PATH", "Invalid relative path", null)
                    }
                    return@launch
                }

                // Navigate/create directories
                var currentDir: DocumentFile = rootDoc
                for (i in 0 until pathParts.size - 1) {
                    val dirName = pathParts[i]
                    var nextDir: DocumentFile? = currentDir.findFile(dirName)

                    if (nextDir == null && createDirs) {
                        nextDir = currentDir.createDirectory(dirName)
                    }

                    if (nextDir == null || !nextDir.isDirectory) {
                        withContext(Dispatchers.Main) {
                            result.error("DIRECTORY_ERROR", "Cannot access directory: $dirName", null)
                        }
                        return@launch
                    }

                    currentDir = nextDir
                }

                // Create or get target file
                val fileName = pathParts.last()
                var targetFile: DocumentFile? = currentDir.findFile(fileName)

                if (targetFile == null) {
                    // Determine MIME type from extension
                    val mimeType = when {
                        fileName.endsWith(".jpg", true) || fileName.endsWith(".jpeg", true) -> "image/jpeg"
                        fileName.endsWith(".png", true) -> "image/png"
                        fileName.endsWith(".webp", true) -> "image/webp"
                        fileName.endsWith(".json", true) -> "application/json"
                        fileName.endsWith(".txt", true) -> "text/plain"
                        else -> "application/octet-stream"
                    }

                    targetFile = currentDir.createFile(mimeType, fileName)
                } else {
                    // File exists - delete it first to start fresh (append simulation)
                    targetFile.delete()
                    val mimeType = when {
                        fileName.endsWith(".jpg", true) || fileName.endsWith(".jpeg", true) -> "image/jpeg"
                        fileName.endsWith(".png", true) -> "image/png"
                        fileName.endsWith(".webp", true) -> "image/webp"
                        fileName.endsWith(".json", true) -> "application/json"
                        fileName.endsWith(".txt", true) -> "text/plain"
                        else -> "application/octet-stream"
                    }
                    targetFile = currentDir.createFile(mimeType, fileName)
                }

                if (targetFile == null) {
                    withContext(Dispatchers.Main) {
                        result.error("CREATE_FILE_ERROR", "Cannot create file: $fileName", null)
                    }
                    return@launch
                }

                // CRITICAL FIX: Open in write mode (SAF doesn't support true append, so we manage chunks in memory)
                val outputStream = contentResolver.openOutputStream(targetFile.uri, "w")
                if (outputStream == null) {
                    withContext(Dispatchers.Main) {
                        result.error("OPEN_OUTPUT_ERROR", "Cannot open file for writing", null)
                    }
                    return@launch
                }

                // Create buffered stream for efficient writing
                val bufferedStream = BufferedOutputStream(outputStream, BUFFER_SIZE)

                // Generate unique session token
                val sessionToken = "write_${writeSessionCounter.incrementAndGet()}_${System.currentTimeMillis()}"

                // Store the session
                activeSessions[sessionToken] = bufferedStream

                withContext(Dispatchers.Main) {
                    result.success(sessionToken)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("BEGIN_WRITE_ERROR", e.message, null)
                }
            }
        }
    }

    // NEW: Write chunk to active session
    private fun writeChunk(token: String, data: ByteArray, result: MethodChannel.Result) {
        ioScope.launch {
            try {
                val session = activeSessions[token]
                if (session == null) {
                    withContext(Dispatchers.Main) {
                        result.error("INVALID_SESSION", "Write session not found: $token", null)
                    }
                    return@launch
                }

                // Write chunk to buffered stream
                session.write(data)

                withContext(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("WRITE_CHUNK_ERROR", e.message, null)
                }
            }
        }
    }

    // NEW: End write session and close stream
    private fun endWrite(token: String, result: MethodChannel.Result) {
        ioScope.launch {
            try {
                val session = activeSessions.remove(token)
                if (session == null) {
                    withContext(Dispatchers.Main) {
                        result.error("INVALID_SESSION", "Write session not found: $token", null)
                    }
                    return@launch
                }

                // Flush and close the stream
                session.flush()
                session.close()

                withContext(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("END_WRITE_ERROR", e.message, null)
                }
            }
        }
    }

    // NEW: Abort write session and clean up
    private fun abortWrite(token: String, result: MethodChannel.Result) {
        ioScope.launch {
            try {
                val session = activeSessions.remove(token)
                if (session != null) {
                    try {
                        session.close()
                    } catch (_: Exception) {
                        // Ignore cleanup errors
                    }
                }

                withContext(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("ABORT_WRITE_ERROR", e.message, null)
                }
            }
        }
    }

    // NEW: Native copy for efficient restore without Binder limits
    private fun copyToLocalFile(
        uriString: String,
        relativePath: String,
        destPath: String,
        result: MethodChannel.Result
    ) {
        ioScope.launch {
            try {
                val rootUri = uriString.toUri()
                val rootDoc = DocumentFile.fromTreeUri(this@MainActivity, rootUri)

                if (rootDoc == null || !rootDoc.exists()) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Root directory not found", null)
                    }
                    return@launch
                }

                val sourceFile = navigateToPath(rootDoc, relativePath)
                if (sourceFile == null || !sourceFile.isFile) {
                    withContext(Dispatchers.Main) {
                        result.error("SOURCE_NOT_FOUND", "Source file not found: $relativePath", null)
                    }
                    return@launch
                }

                val destFile = File(destPath)

                // Ensure destination directory exists
                destFile.parentFile?.mkdirs()

                // Stream copy without loading entire file into memory
                val inputStream = contentResolver.openInputStream(sourceFile.uri)
                if (inputStream == null) {
                    withContext(Dispatchers.Main) {
                        result.error("OPEN_SOURCE_ERROR", "Cannot open source file", null)
                    }
                    return@launch
                }

                val outputStream = FileOutputStream(destFile)

                inputStream.use { input ->
                    outputStream.use { output ->
                        val buffer = ByteArray(BUFFER_SIZE)
                        var bytesRead: Int
                        while (input.read(buffer).also { bytesRead = it } != -1) {
                            output.write(buffer, 0, bytesRead)
                        }
                        output.flush()
                    }
                }

                withContext(Dispatchers.Main) {
                    result.success(destFile.absolutePath)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("COPY_ERROR", e.message, null)
                }
            }
        }
    }

    private fun makeDirectories(uriString: String, relativeDir: String, result: MethodChannel.Result) {
        try {
            val rootUri = uriString.toUri()
            val rootDoc = DocumentFile.fromTreeUri(this, rootUri)

            if (rootDoc == null || !rootDoc.exists()) {
                result.error("NOT_FOUND", "Root directory not found", null)
                return
            }

            val pathParts = relativeDir.split("/").filter { it.isNotEmpty() }
            var currentDir: DocumentFile = rootDoc

            for (dirName in pathParts) {
                var nextDir: DocumentFile? = currentDir.findFile(dirName)

                if (nextDir == null) {
                    nextDir = currentDir.createDirectory(dirName)
                }

                if (nextDir == null || !nextDir.isDirectory) {
                    result.error("CREATE_DIR_ERROR", "Cannot create directory: $dirName", null)
                    return
                }

                currentDir = nextDir
            }

            result.success(true)
        } catch (e: Exception) {
            result.error("MKDIR_ERROR", e.message, null)
        }
    }

    private fun renameFile(
        uriString: String,
        fromPath: String,
        toPath: String,
        result: MethodChannel.Result
    ) {
        try {
            val rootUri = uriString.toUri()
            val rootDoc = DocumentFile.fromTreeUri(this, rootUri)

            if (rootDoc == null || !rootDoc.exists()) {
                result.error("NOT_FOUND", "Root directory not found", null)
                return
            }

            val sourceFile = navigateToPath(rootDoc, fromPath)
            if (sourceFile == null || !sourceFile.exists()) {
                result.error("SOURCE_NOT_FOUND", "Source file not found", null)
                return
            }

            // Extract new filename from toPath
            val newName = toPath.split("/").last()
            val success = sourceFile.renameTo(newName)

            result.success(success)
        } catch (e: Exception) {
            result.error("RENAME_ERROR", e.message, null)
        }
    }

    private fun deleteFile(uriString: String, relativePath: String, result: MethodChannel.Result) {
        try {
            val rootUri = uriString.toUri()
            val rootDoc = DocumentFile.fromTreeUri(this, rootUri)

            if (rootDoc == null || !rootDoc.exists()) {
                result.error("NOT_FOUND", "Root directory not found", null)
                return
            }

            val targetFile = navigateToPath(rootDoc, relativePath)
            if (targetFile == null || !targetFile.exists()) {
                result.success(true) // Already deleted
                return
            }

            val success = targetFile.delete()
            result.success(success)
        } catch (e: Exception) {
            result.error("DELETE_ERROR", e.message, null)
        }
    }

    private fun getPersistedUris(result: MethodChannel.Result) {
        try {
            val persistedUris = contentResolver.persistedUriPermissions
            val uriList = persistedUris.map { permission ->
                mapOf(
                    "uri" to permission.uri.toString(),
                    "canRead" to permission.isReadPermission,
                    "canWrite" to permission.isWritePermission
                )
            }
            result.success(uriList)
        } catch (e: Exception) {
            result.error("PERMISSION_ERROR", e.message, null)
        }
    }

    private fun navigateToPath(root: DocumentFile, relativePath: String): DocumentFile? {
        val parts = relativePath.split("/").filter { it.isNotEmpty() }
        var current = root

        for (part in parts) {
            current = current.findFile(part) ?: return null
        }

        return current
    }
}