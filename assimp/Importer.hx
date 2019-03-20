package assimp;
import assimp.IOSystem.MemoryIOStream;
import assimp.IOSystem.IOStream;
import assimp.IOSystem.MemoryIOSystem;
import haxe.io.Bytes;
import Lambda;
import Lambda;
import assimp.AiPostProcessStep;
import assimp.postProcess.ValidateDSProcess;
import assimp.format.Scene.AiScene;
import assimp.Types.AiReturn;
import assimp.AiPostProcessStep as Pps;
class Importer {
    var prograssHandler:ProgressHandler;
    static var impl = new ImporterPimpl(); // allocate the pimpl first

    public function new() {
    }

    public function getErrorString():String {
        return "";
    }
    /** Registers a new loader.
     *
     *  @param imp Importer to be added. The Importer instance takes ownership of the pointer, so it will be
     *  automatically deleted with the Importer instance.
     *  @return AI_SUCCESS if the loader has been added. The registration fails if there is already a loader for a
     *  specific file extension.
     */
    public function registerLoader(imp:BaseImporter):AiReturn {
        /*  --------------------------------------------------------------------
            Check whether we would have two loaders for the same file extension
            This is absolutely OK, but we should warn the developer of the new loader that his code will probably never
            be called if the first loader is a bit too lazy in his file checking.
            --------------------------------------------------------------------    */
        var st:Array<String> = imp.extensionList();
        var baked = "";
        for (it in st) {
            if (Assimp.DEBUG && isExtensionSupported(it))
                trace("The file extension $it is already in use");
            baked += "$it ";
        }
        // add the loader
        impl.importer.push(imp);
        trace("Registering custom importer for these file extensions: $baked");
        return AiReturn.SUCCESS;
    }

    /** Unregisters a loader.
     *
     *  @param imp Importer to be unregistered.
     *  @return AI_SUCCESS if the loader has been removed. The function fails if the loader is currently in use (this
     *  could happen if the Importer instance is used by more than one thread) or if it has not yet been registered.
     */
    public function unregisterLoader(imp:BaseImporter) {
        return if (impl.importer.remove(imp)) {
            trace("Unregistering custom importer: ");
            AiReturn.SUCCESS;
        } else {
            trace("Unable to remove custom importer: I can't find you ...");
            AiReturn.FAILURE;
        }
    }

    /** Registers a new post-process step.
     *
     *  At the moment, there's a small limitation: new post processing steps are added to end of the list, or in other
     *  words, executed last, after all built-in steps.
     *  @param imp Post-process step to be added. The Importer instance takes ownership of the pointer, so it will be
     *  automatically deleted with the Importer instance.
     *  @return AI_SUCCESS if the step has been added correctly.
     */
    public function registerPPStep(imp:BaseProcess):AiReturn {
        impl.postProcessingSteps.push(imp);
        trace("Registering custom post-processing step");
        return AiReturn.SUCCESS;
    }

    /** Unregisters a post-process step.
     *
     *  @param imp Step to be unregistered.
     *  @return AI_SUCCESS if the step has been removed. The function fails if the step is currently in use (this could happen
     *   if the #Importer instance is used by more than one thread) or
     *   if it has not yet been registered.
     */
    public function unregisterPPStep(imp:BaseProcess) {
        return if (impl.postProcessingSteps.remove(imp)) {
            trace("Unregistering custom post-processing step");
            AiReturn.SUCCESS ;
        }
        else {
            trace("Unable to remove custom post-processing step: I can't find you ..");
            AiReturn.FAILURE;
        }
    }

    inline public function set<T>(szName:String, value:T) {
        impl.properties.set(Hash.superFastHash(szName), value);
    }

    inline public function get<T>(szName:String):T {
        return impl.properties.get(Hash.superFastHash(szName));
    }

    private function writeLogOpening(file:String) {
    }

    public var progressHandler(get, set):ProgressHandler;

    function get_progressHandler() return impl.progressHandler;

    function set_progressHandler(value) {
        impl.progressHandler = value;
        return value;
    }

    public var ioHandler(get, set):IOSystem;

    function get_ioHandler() return impl.ioSystem;

    function set_ioHandler(value) {
        impl.ioSystem = value;
        return value;
    }

    public function readFile(file:String, ioSystem:IOSystem, flags:Pps):AiScene {

        writeLogOpening(file);

        // Check whether this Importer instance has already loaded a scene. In this case we need to delete the old one
        if (impl.scene != null) {
            trace("(Deleting previous scene)");
            freeScene();
        }

        // First check if the file is accessible at all
        // handled by exception in IOSystem
        /*if (!file.exists()) {
            impl.errorString = "Unable to open file \"$file\"."
            logger.error { impl.errorString }
            return null
        }*/

//        TODO std::unique_ptr<Profiler> profiler(GetPropertyInteger(AI_CONFIG_GLOB_MEASURE_TIME,0)?new Profiler():NULL);
//        if (profiler) {
//            profiler->BeginRegion("total");
//        }

        // Find an worker class which can handle the file
        var stream:IOStream=ioHandler.open(file);
        readFileFromStream(file,stream,flags);
        ioHandler.close(stream);
        return impl.scene;
    }

    public function readFileFromMemory(buffer:Bytes, flags:Int, hint:String = ""):AiScene {
        var MaxLenHint = 200;
        if (buffer.length == 0 || hint.length > MaxLenHint) {
            impl.errorString = "Invalid parameters passed to ReadFileFromMemory()";
            return null;
        }
        var AI_MEMORYIO_MAGIC_FILENAME="___magic___";
        var fileName = AI_MEMORYIO_MAGIC_FILENAME+"."+hint;
        var stream = new MemoryIOStream( buffer);
        if (impl.scene != null) {
            trace("(Deleting previous scene)");
            freeScene();
        }
        return readFileFromStream(fileName,stream,flags);
    }

    function readFileFromStream(file:String,stream:IOStream,flags:Int){
        var imp:BaseImporter = Lambda.find(impl.importer, function(it:BaseImporter)return it.canRead(file, stream, false));

        if (imp == null) {
            trace("Assimp could not find an importer for the file!");
            return null;
            // not so bad yet ... try format auto detection.
            // TODO()
//            const std::string::size_type s = pFile.find_last_of('.');
//            if (s != std::string::npos) {
//                DefaultLogger::get()->info("File extension not known, trying signature-based detection");
//                for( unsigned int a = 0; a < pimpl->mImporter.size(); a++)  {
//
//                    if( pimpl->mImporter[a]->CanRead( pFile, pimpl->mIOHandler, true)) {
//                    imp = pimpl->mImporter[a];
//                    break;
//                }
//                }
//            }
//            // Put a proper error message if no suitable importer was found
//            if( !imp)   {
//                pimpl->mErrorString = "No suitable reader found for the file format of file \"" + pFile + "\".";
//                DefaultLogger::get()->error(pimpl->mErrorString);
//                return NULL;
//            }
        }

        // Get file size for progress handler
        var fileSize = stream.length;

        // Dispatch the reading to the worker class for this format
        var desc = imp.info;
        var ext = desc.name;
        trace("Found a matching importer for this file format: $ext.");
        impl.progressHandler.updateFileRead(0, fileSize);

//        if (profiler) { TODO
//            profiler->BeginRegion("import");
//        }

        impl.scene = imp.readFile(impl, stream, file);
        impl.progressHandler.updateFileRead(fileSize, fileSize);

//        if (profiler) { TODO
//            profiler->EndRegion("import");
//        }

        // If successful, apply all active post processing steps to the imported data
        if (impl.scene != null) {

            if (!Assimp.NO.VALIDATEDS_PROCESS)
                // The ValidateDS process is an exception. It is executed first, even before ScenePreprocessor is called.
            if (flags & Pps.ValidateDataStructure != 0) {
                new ValidateDSProcess().executeOnScene(impl);
                if (impl.scene == null) return null;
            }
            // Preprocess the scene and prepare it for post-processing
//            if (profiler) profiler.BeginRegion("preprocess")

            new ScenePreprocessor().processScene(impl.scene);

//            if (profiler) profiler.EndRegion("preprocess")

            // Ensure that the validation process won't be called twice
            applyPostProcessing(flags & ~ Pps.ValidateDataStructure);
        }
            // if failed, extract the error string
        else if (impl.scene == null)
            impl.errorString = imp.errorText;
//        if (profiler) { profiler ->
//            EndRegion("total");
//        }

        return impl.scene;
    }
    /** Apply post-processing to an already-imported scene.
     *
     *  This is strictly equivalent to calling readFile() with the same flags. However, you can use this separate
     *  function to inspect the imported scene first to fine-tune your post-processing setup.
     *  @param flags_ Provide a bitwise combination of the AiPostProcessSteps flags.
     *  @return A pointer to the post-processed data. This is still the same as the pointer returned by readFile().
     *  However, if post-processing fails, the scene could now be null.
     *  That's quite a rare case, post processing steps are not really designed to 'fail'. To be exact, the
     *  AiProcess_ValidateDS flag is currently the only post processing step which can actually cause the scene to be
     *  reset to null.
     *
     *  @note The method does nothing if no scene is currently bound to the Importer instance.  */
    public function applyPostProcessing(flags_:Int):AiScene {
        // Return immediately if no scene is active
        if (impl.scene == null) return null;
        // If no flags are given, return the current scene with no further action
        if (flags_ == 0) return impl.scene ;
        return impl.scene;
    }

    public function applyCustomizedPostProcessing(rootProcess:BaseProcess, requestValidation:Bool):AiScene {
        // Return immediately if no scene is active
        if (null == impl.scene) return null;
        // If no flags are given, return the current scene with no further action
        if (null == rootProcess) return impl.scene;
        // In debug builds: run basic flag validation
        trace("Entering customized post processing pipeline");
        if (!Assimp.NO.VALIDATEDS_PROCESS) {
            // The ValidateDS process plays an exceptional role. It isn't contained in the global
            // list of post-processing steps, so we need to call it manually.
            if (requestValidation) {
                new ValidateDSProcess().executeOnScene(impl);
                if (impl.scene == null) return null;
            }
        }
        if (Assimp.DEBUG && impl.extraVerbose && Assimp.NO.VALIDATEDS_PROCESS)
            trace("Verbose Import is not available due to build settings");
        else if (impl.extraVerbose)
            trace("Not a debug build, ignoring extra verbose setting");

//        std::unique_ptr<Profiler> profiler (GetPropertyInteger(AI_CONFIG_GLOB_MEASURE_TIME, 0) ? new Profiler() : NULL);
//        if (profiler) { profiler ->
//            BeginRegion("postprocess");
//        }
        rootProcess.executeOnScene(impl);
//        if (profiler) { profiler ->
//            EndRegion("postprocess")
//        }
        // If the extra verbose mode is active, execute the ValidateDataStructureStep again - after each step
        if (impl.extraVerbose || requestValidation) {
            trace("Verbose Import: revalidating data structures");
            new ValidateDSProcess().executeOnScene(impl);
            if (impl.scene == null)
                trace("Verbose Import: failed to revalidate data structures");
        }
        trace("Leaving customized post processing pipeline");
        return impl.scene;
    }

    /** Frees the current scene.
     *
     *  The function does nothing if no scene has previously been read via readFile(). freeScene() is called
     *  automatically by the destructor and readFile() itself.  */
    public function freeScene() {
        impl.scene = null;
        impl.errorString = "";
    }

    /** Returns an error description of an error that occurred in ReadFile().
     *
     *  Returns an empty string if no error occurred.
     *  @return A description of the last error, an empty string if no error occurred. The string is never null.
     *
     *  @note The returned function remains valid until one of the following methods is called: readFile(),
     *  freeScene(). */
    public function errorString() return impl.errorString;

    /** Returns the scene loaded by the last successful call to readFile()
     *
     *  @return Current scene or null if there is currently no scene loaded */
    public function scene() return impl.scene;

    /** Returns whether a given file extension is supported by ASSIMP.
     *
     *  @param szExtension Extension to be checked.
     *  Must include a trailing dot '.'. Example: ".3ds", ".md3". Cases-insensitive.
     *  @return true if the extension is supported, false otherwise */
    public function isExtensionSupported(szExtension:String) return null != getImporterExtension(szExtension);

    /** Get a full list of all file extensions supported by ASSIMP.
     *
     *  If a file extension is contained in the list this does of course not mean that ASSIMP is able to load all files
     *  with this extension --- it simply means there is an importer loaded which claims to handle files with this
     *  file extension.
     *  @return String containing the extension list.
     *  Format of the list: "*.3ds;*.obj;*.dae". This is useful for use with the WinAPI call GetOpenFileName(Ex). */
    public function extensionList():List<String> return Lambda.flatten(impl.importer.map(function(e) return e.extensionList()));

    /** Get the number of importers currently registered with Assimp. */
    public function importerCount() return impl.importer.length;

    /** Get meta data for the importer corresponding to a specific index..
     *
     *  @param index Index to query, must be within [0, importerCount)
     *  @return Importer meta data structure, null if the index does not exist or if the importer doesn't offer meta
     *  information (importers may do this at the cost of being hated by their peers).  TODO JVM DOESNT ALLOW THIS */
    public function getImporterInfo(index:Int) return impl.importer[index].info;

    /** Find the importer corresponding to a specific index.
     *
     *  @param index Index to query, must be within [0, importerCount)
     *  @return Importer instance. null if the index does not exist. */
    public function getImporter(index:Int) return impl.importer.length > index ? impl.importer[index] : null;

    /** Find the importer corresponding to a specific file extension.
     *
     *  This is quite similar to `isExtensionSupported` except a BaseImporter instance is returned.
     *  @param szExtension Extension to check for. The following formats are recognized (BAH being the file extension):
     *  "BAH" (comparison is case-insensitive), ".bah", "*.bah" (wild card and dot characters at the beginning of the
     *  extension are skipped).
     *  @return null if no importer is found*/
    public function getImporterExtension(szExtension:String) return getImporter(getImporterIndex(szExtension));

    /** Find the importer index corresponding to a specific file extension.
     *
     *  @param szExtension Extension to check for. The following formats are recognized (BAH being the file extension):
     *  "BAH" (comparison is case-insensitive), ".bah", "*.bah" (wild card and dot characters at the beginning of the
     *  extension are skipped).
     *  @return -1 if no importer is found */
    public function getImporterIndex(szExtension:String):Int {
//assert(szExtension.isNotEmpty())
        // skip over wildcard and dot characters at string head --
        var p = 0;
        while (szExtension.charAt(p) == '*' || szExtension.charAt(p) == '.') ++p;
        var ext = szExtension.substring(p);
        if (ext == "") return -1;
        ext = ext.toLowerCase();
        return Lambda.indexOf(impl.importer, Lambda.find(impl.importer, function(i:BaseImporter) {
            return Lambda.has(i.extensionList(), ext) ;
        }));
    }

    private function _validateFlags(flags:Int) {
        if (flags & Pps.GenSmoothNormals != 0 && flags & Pps.GenNormals != 0) {
            trace("AiProcess_GenSmoothNormals and AiProcess_GenNormals are incompatible");
            return false;
        }
        if (flags & Pps.OptimizeGraph != 0 && flags & Pps.PreTransformVertices != 0) {
            trace("AiProcess_OptimizeGraph and AiProcess_PreTransformVertices are incompatible");
            return false;
        }
        return true;
    }
}

