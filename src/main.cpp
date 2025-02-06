//
//  SublayerZ.cpp
//  AllHail
//
//  Created by Michael B. Johnson on 1/28/25.
//

// Build USD thusly:
/*
python3 ./build_scripts/build_usd.py \
     --build-monolithic \
     --no-examples --no-tools --no-docs \
     --no-materialx \
     --no-python \
     --no-usdValidation \
     --no-imaging \
     --no-tutorials \
     /opt/local/OpenUSD_V25_02MinMono
*/

// will have to either copy next to executable:
// - libtbb.dylib
// - libtbbmalloc.dylib
// - libusd_ms.dylib
// or do:
// export DYLD_FALLBACK_LIBRARY_PATH=/opt/local/OpenUSD_V25_02MinMono/lib


#include <pxr/usd/usd/stage.h>
#include <iostream>

int main(int argc, char* argv[]) {
    // Create a new USD stage (or open an existing one)
    const std::string stageFile = "scene.usda";
    pxr::UsdStageRefPtr stage = pxr::UsdStage::CreateNew(stageFile);
    if (!stage) {
        std::cerr << "Failed to create USD stage." << std::endl;
        return 1;
    }
    auto rootLayer = stage->GetRootLayer();
    if (!rootLayer) {
        std::cerr << "Failed to root layer." << std::endl;
        return 1;
    }
    std::string subLayerPath("./ShinyBall.usdz");
    // insert this USDZ as the top subLayer
    rootLayer->InsertSubLayerPath(subLayerPath, 0);
    
    // Save the USD stage to disk
    rootLayer->Save();
    
    std::cout << "USD stage created and saved: " << stageFile << std::endl;
    return 0;
}

/*
 
 Works fine in 24.08 and 24.11:
 
 #usda 1.0
 (
     subLayers = [
         @./ShinyBall.usdz@
     ]
 )


 In 25.02:
 
 Coding Error: in _CreateAnonymousWithFormat at line 370 of /Users/drwave/git/OpenUSD/pxr/usd/sdf/layer.cpp -- Cannot create anonymous layer: creating package usdz layer is not allowed through this API.

 ----------------------------- SublayerZ terminated -----------------------------
 SublayerZ crashed. FATAL ERROR: attempted member lookup on NULL TfRefPtr<SdfLayer>
 in operator-> at line 933 of /Users/drwave/git/OpenUSD/pxr/base/tf/refPtr.h
 writing crash report to [ Mac.localdomain:/var/folders/8q/4zz9spc91c7fx9vh8p9msc5m0000gp/T//st_SublayerZ.40311 ] ... done.
 --------------------------------------------------------------------------------

 */
