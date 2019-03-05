package assimp;
/*
Open Asset Import Library (assimp)
----------------------------------------------------------------------

Copyright (c) 2006-2017, assimp team

All rights reserved.

Redistribution and use of this software in source and binary forms,
with or without modification, are permitted provided that the
following conditions are met:

* Redistributions of source code must retain the above
  copyright notice, this list of conditions and the
  following disclaimer.

* Redistributions in binary form must reproduce the above
  copyright notice, this list of conditions and the
  following disclaimer in the documentation and/or other
  materials provided with the distribution.

* Neither the name of the assimp team, nor the names of its
  contributors may be used to endorse or promote products
  derived from this software without specific prior
  written permission of the assimp team.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

----------------------------------------------------------------------
*/

// ---------------------------------------------------------------------------
/** Helper class to allow post-processing steps to interact with each other.
 *
 *  The class maintains a simple property list that can be used by pp-steps
 *  to provide additional information to other steps. This is primarily
 *  intended for cross-step optimizations.
 */
import assimp.format.Scene.AiScene;
import haxe.ds.IntMap;
class SharedPostProcessInfo {


    /** Map of all stored properties    */
    var map:IntMap<Any>;

    /** Add a property to the list  */
    public function addProperty(name:String, data:Any) {
        // setGenericPropertyPtr(map, name, data)
    }

    /** Get a heap property */
    public function getProperty(name:String) {
        //getGenericProperty(map, name)
    }

    /** Remove a property of a specific type    */
    public function removeProperty(name:String) {
        //setGenericPropertyPtr(map, name)
    }
}
class BaseProcess {
    public function new() {
    }


// ---------------------------------------------------------------------------
/** The BaseProcess defines a common interface for all post processing steps.
 *  A post processing step is run after a successful import if the caller specified the corresponding flag when calling
 *  readFile().
 *  Enum AiPostProcessSteps defines which flags are available.
 *  After a successful import the Importer iterates over its internal array of processes and calls isActive()
 *  on each process to evaluate if the step should be executed. If the function returns true, the class' Execute()
 *  function is called subsequently.
 */
/** Constructor to be privately used by Importer */

    /** See the doc of #SharedPostProcessInfo for more details */
    var shared:SharedPostProcessInfo;

    /** Currently active progress handler */
    var progress:ProgressHandler;

    /** -------------------------------------------------------------------
     *  Returns whether the processing step is present in the given flag.
     *  @param flags The processing flags the importer was called with. A bitwise combination of AiPostProcessSteps.
     *  @return true if the process is present in this flag fields, false if not.
     */
    public function isActive(flags:Int):Bool {
        return false;
    }

    // -------------------------------------------------------------------
    /** Check whether this step expects its input vertex data to be in verbose format. */
    var requireVerboseFormat:Bool;// = true

    // -------------------------------------------------------------------
    /** Executes the post processing step on the given imported data.
     *  The function deletes the scene if the postprocess step fails ( the object pointer will be set to null).
     *  @param imp Importer instance (imp.scene must be valid)
     */
    public function executeOnScene(imp:ImporterPimpl) {
//assert(imp.impl.scene != null)

        progress = imp.progressHandler;

        setupProperties(imp);

        // catch exceptions thrown inside the PostProcess-Step

        execute(imp.scene);
    }

    // -------------------------------------------------------------------
    /** Called prior to executeOnScene().
     *  The function is a request to the process to update its configuration basing
     *  on the Importer's configuration property list.
     */
    public function setupProperties(imp:ImporterPimpl) {

    }

    // -------------------------------------------------------------------
    /** Executes the post processing step on the given imported data.
     *  A process should throw an ImportErrorException* if it fails.
     *  This method must be implemented by deriving classes.
     *  @param scene The imported data to work at.
     */
    public function execute(scene:AiScene) {

    }
}