//
//  SceneProxy.h
//  TinyUSDTester
//
//  Created by Aaron Hilton on 2019-11-05.
//  Copyright © 2019 Steampunk Digital, Co. Ltd. All rights reserved.
//

#ifndef SceneProxy_h
#define SceneProxy_h

#pragma warning(disable:4244)
#pragma warning(disable:4305)

#include <pxr/base/tf/weakBase.h>
#include <pxr/base/tf/weakPtr.h>
#include <pxr/usd/usd/notice.h>
#include <pxr/usd/usd/prim.h>
#include <pxr/usd/usd/stage.h>
#include <pxr/usd/usdGeom/xformable.h>

PXR_NAMESPACE_USING_DIRECTIVE

class SceneProxy : public TfWeakBase         // in order to register for Tf events
{
    // For changes from UsdStage.
    TfNotice::Key _objectsChangedNoticeKey;
    UsdStageRefPtr stage;
public:

    ~SceneProxy();

    void _OnObjectsChanged(UsdNotice::ObjectsChanged const& notice, UsdStageWeakPtr const& sender);

    void create_new_stage(std::string const& path);
    void load_stage(std::string const& filePath);
    void save_stage();
};


#endif /* SceneProxy_h */
