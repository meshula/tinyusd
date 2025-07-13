//
// TinyUSD - Hello Cube
// A minimal USD program that creates a simple cube geometry
//

#include <pxr/usd/usd/stage.h>
#include <pxr/usd/usdGeom/cube.h>
#include <pxr/usd/usdGeom/xform.h>
#include <iostream>

int main(int argc, char* argv[]) {
    // Create a new USD stage
    const std::string stageFile = "cube.usda";
    pxr::UsdStageRefPtr stage = pxr::UsdStage::CreateNew(stageFile);
    if (!stage) {
        std::cerr << "Failed to create USD stage." << std::endl;
        return 1;
    }

    // Create a transform (Xform) prim as the root
    pxr::UsdGeomXform xform = pxr::UsdGeomXform::Define(stage, pxr::SdfPath("/HelloCube"));
    if (!xform) {
        std::cerr << "Failed to create Xform prim." << std::endl;
        return 1;
    }

    // Create a cube geometry under the transform
    pxr::UsdGeomCube cube = pxr::UsdGeomCube::Define(stage, pxr::SdfPath("/HelloCube/Cube"));
    if (!cube) {
        std::cerr << "Failed to create Cube prim." << std::endl;
        return 1;
    }

    // Set the cube size (2x2x2 units)
    cube.CreateSizeAttr().Set(2.0);

    // Save the stage to disk
    stage->GetRootLayer()->Save();

    std::cout << "Hello Cube USD stage created and saved: " << stageFile << std::endl;
    return 0;
}
