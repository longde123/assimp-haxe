package assimp;
import assimp.format.assbin.AssbinLoader;
import haxe.ds.IntMap;
import assimp.format.Scene.AiScene;
class ImporterPimpl {
    /** Format-specific importer worker objects - one for each format we can read.*/
    public var importer:Array<BaseImporter> ;

    /** Post processing steps we can apply at the imported data. */
    public var postProcessingSteps:Array<BaseProcess> ;


/** Progress handler for feedback. */
    public var progressHandler:ProgressHandler ;//= DefaultProgressHandler()
    public var isDefaultProgressHandler:Bool;//= true

    public var ioSystem:IOSystem;// = DefaultIOSystem()


    /** The imported data, if ReadFile() was successful, NULL otherwise. */
    public var scene:AiScene;// = null

    /** The error description, if there was one. */
    public var errorString:String;//= ""

    public var properties:IntMap<Any>;

    /** Used for testing - extra verbose mode causes the ValidateDataStructure-Step to be executed before and after
     *  every single postprocess step
     *  disable extra verbose mode by default    */
    public var extraVerbose:Bool;// = false

    /** Used by post-process steps to share data
     *  Allocate a SharedPostProcessInfo object and store pointers to it in all post-process steps in the list. */
    public var ppShared:Array<Any>;// = SharedPostProcessInfo().also { info -> postProcessingSteps.forEach { it.shared = info } }
    public function new() {
        properties=new IntMap<Any>();
        ppShared=[];
        importer = importerInstanceList();

        postProcessingSteps = postProcessingStepInstanceList();
    }

    public function isDefaultHandler() return Std.is(ioSystem, DefaultIOSystem);

    public function importerInstanceList():Array<BaseImporter> {
        return [new AssbinLoader()];
    }

    public function postProcessingStepInstanceList() {
        return [];
    }


}
