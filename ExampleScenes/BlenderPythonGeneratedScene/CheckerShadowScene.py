def makeShadowCheckerScene(sceneParams): 
  # Import the Blender-Python API module
  import bpy
  # Import necessary system modules
  import sys
  import imp
  # Import necessary math functions from the math and mathutils modules
  from math import pi, floor
  from mathutils import Vector

  # Append the path to custom, SceneUtils Python module to Blender's scripts path
  sys.path.append(sceneParams['toolboxDirectory']);
 
  # Import the custom scene toolbox module
  import SceneUtilsV1;
  imp.reload(SceneUtilsV1);
 
  # Initialize a sceneManager
  params = {'name'               : sceneParams['sceneName'],  # name of new scene
            'erasePreviousScene' : True,                      # erase old scene
            'sceneWidthInPixels' : 1000,                      # 1000 pixels along the horizontal-dimension
            'sceneHeightInPixels': 750,                       # 750 pixels along the vertical-dimension
            'sceneUnitScale'     : 1.0/100.0,                 # set unit scale to 1.0 cm
            'sceneGridSpacing'   : 10.0/100.0,                # set the spacing between grid lines to 10 cm
            'sceneGridLinesNum'  : 20,                        # display 20 grid lines
          };
  scene = SceneUtilsV1.sceneManager(params);


 
  # Generate the materials
  # 1. Generate dictionary with specs for the cylinder material. These can be changed in RenderToolbox3.
  params = { 'name'              : 'cylinderMaterial',           # tag with which RenderToolbox3 can access this material
           'diffuse_shader'    : 'LAMBERT',
           'diffuse_intensity' : 0.5,
           'diffuse_color'     : Vector((0.0, 1.0, 0.0)),
           'specular_shader'   : 'WARDISO',
           'specular_intensity': 0.1,
           'specular_color'    : Vector((0.0, 1.0, 0.0)),
           'alpha'             : 1.0
         }; 
  cylinderMaterialType = scene.generateMaterialType(params);

  # 2. Generate dictionary with specs for the room (walls) material. These can be changed in RenderToolbox3.
  params = { 'name'              : 'roomMaterial',              # tag with which RenderToolbox3 can access this material
           'diffuse_shader'    : 'LAMBERT',
           'diffuse_intensity' : 0.5,
           'diffuse_color'     : Vector((0.6, 0.6, 0.6)),
           'specular_shader'   : 'WARDISO',
           'specular_intensity': 0.0,
           'specular_color'    : Vector((1.0, 1.0, 1.0)),
           'alpha'             : 1.0
         }; 
  roomMaterialType = scene.generateMaterialType(params);

  # 3. Generate dictionary with specs for the cloth material. These can be changed in RenderToolbox3.
  params = { 'name'              : 'clothMaterial',            # tag with which RenderToolbox3 can access this material
           'diffuse_shader'    : 'LAMBERT',
           'diffuse_intensity' : 0.5,
           'diffuse_color'     : Vector((0.7, 0.0, 0.1)),
           'specular_shader'   : 'WARDISO',
           'specular_intensity': 0.0,
           'specular_color'    : Vector((0.7, 0.0, 0.1)),
           'alpha'             : 1.0
         }; 
  clothMaterialType = scene.generateMaterialType(params);

  # 4. Generate dictionary with specs for the dark check material. These can be changed in RenderToolbox3.
  params = { 'name'              : 'darkCheckMaterial',        # tag with which RenderToolbox3 can access this material
           'diffuse_shader'    : 'LAMBERT',
           'diffuse_intensity' : 0.1,
           'diffuse_color'     : Vector((0.5, 0.5, 0.5)),
           'specular_shader'   : 'WARDISO',
           'specular_intensity': 0.0,
           'specular_color'    : Vector((0.5, 0.5, 0.5)),
           'alpha'             : 1.0
         }; 
  darkCheckMaterialType = scene.generateMaterialType(params);

  # 5. Generate dictionary with specs for the light check material. These can be changed in RenderToolbox3.
  params = { 'name'              : 'lightCheckMaterial',       # tag with which RenderToolbox3 can access this material
           'diffuse_shader'    : 'LAMBERT',
           'diffuse_intensity' : 0.7,
           'diffuse_color'     : Vector((0.55, 0.55, 0.40)),
           'specular_shader'   : 'WARDISO',
           'specular_intensity': 0.0,
           'specular_color'    : Vector((0.5, 0.5, 0.5)),
           'alpha'             : 1.0
         }; 
  lightCheckMaterialType = scene.generateMaterialType(params);

  # Generate list of materials
  checkBoardMaterialsList = [lightCheckMaterialType, darkCheckMaterialType];



  # Generate an area lamp model
  params = {'name'           : 'areaLampModel',    # tag with which RenderToolbox3 can access this lamp model
            'color'          : Vector((1,1,1)),    # white color
            'fallOffDistance': 120,                # distance at which intensity falls to 0.5 
            'width1'         : 20,                 # width of the area lamp
            'width2'         : 15                  # height of the area lamp
          };
  brightLight100 = scene.generateAreaLampType(params);
 
  # Add the left area lamp
  # Position of lamp
  leftAreaLampPosition = Vector((
                            -56,      # horizontal position (x-coord)
                             56,      # depth position (y-coord)
                             16       # elevation (z-coord)
                           ));
  # Point at which the lamp is directed to
  leftAreaLampLooksAt = Vector((
                            -71,          # horizontal position (x-coord)
                             71,          # depth position (y-coord)
                             20           # elevation (z-coord)
                           ));
  # Generate dictionary containing the lamp name and model, its location and direction
  params = {'name'     : 'leftAreaLamp',   # tag with which RenderToolbox3 can access this lamp object
            'model'    : brightLight100, 
            'showName' : True, 
            'location' : leftAreaLampPosition, 
            'lookAt'   : leftAreaLampLooksAt
          };
  # Add the lamp to the scene
  leftAreaLamp = scene.addLampObject(params);


  # Add the front area lamp
  # Position of lamp
  frontAreaLampPosition = Vector((
                              0,      # horizontal position (x-coord)
                            -50,      # depth position (y-coord)
                             50       # elevation (z-coord)
                             ));
  # Point at which the lamp is directed to
  frontAreaLampLooksAt = Vector((
                              0,      # horizontal position (x-coord)
                            -90,      # depth position (y-coord)
                             90       # elevation (z-coord)
                             ));
  # Generate dictionary containing properties of the second lamp.
  params = { 'name'     : 'frontAreaLamp',      # tag with which RenderToolbox3 can access this lamp object
           'model'    : brightLight100, 
           'showName' : True, 
           'location' : frontAreaLampPosition, 
           'lookAt'   : frontAreaLampLooksAt
          };
  # Add the lamp to the scene
  frontAreaLamp = scene.addLampObject(params);


  # Camera setup
  nearClipDistance = 0.1;   
  farClipDistance  = 300;
  # Generate dictionary containing our camera specs.
  params = {'clipRange'            : Vector((nearClipDistance ,  farClipDistance)),  # clipping range (depth)
            'fieldOfViewInDegrees' : 36,                                             # horizontal FOV
            'drawSize'             : 2,                                              # camera wireframe size
          };
  # Generate camera model
  cameraType = scene.generateCameraType(params);
 
  # Generate dictionary containing our camera's name and model, its location and direction.
  cameraHorizPosition = -57;
  cameraDepthPosition = -74;
  cameraElevation     = 45;
  params = {'name'       : 'Camera',                  # tag with which RenderToolbox3 can access this camera object
            'cameraType' : cameraType,
            'location'   : Vector((cameraHorizPosition, cameraDepthPosition, cameraElevation)),     
            'lookAt'     : Vector((-13,-17,10)),
            'showName'   : True,
          };   
  # Add an instance of this camera model       
  mainCamera = scene.addCameraObject(params);



  # Checkerboard
  # Define the checkerboard geometry
  boardThickness    = 2.5;
  boardHalfWidth    = 14;
  tilesAlongEachDim = 4;        
  boardIsDimpled    = True;

  # Compute checker size
  N                 = floor(tilesAlongEachDim/2);
  deltaX            = boardHalfWidth/N;
  deltaY            = deltaX;

  # Generate dictionary with tile parameters
  tileParams = {'name'     : '',
                'scaling'  : Vector((deltaX/2, deltaY/2, boardThickness/2)),
                'rotation' : Vector((0,0,0)), 
                'location' : Vector((0,0,0)),
                'material' : checkBoardMaterialsList[0]
             };
                  
  # Add the checks of the checkerboard
  for ix in list(range(-N,N+1)):
    for iy in list(range(-N,N+1)): 
        tileParams['name']     = 'floorTileAt({0:1d},{1:2d})'.format(ix,iy);
        tileParams['location'] =  Vector((ix*deltaX, iy*deltaY, boardThickness*0.5));
        tileParams['material'] =  checkBoardMaterialsList[(ix+iy)%2];
        theTile = scene.addCube(tileParams);



  if sceneParams['boardIsDimpled]:
    # Generate dictionary with sphere parameters
    sphereParams = {'name'     : 'theSphere',
                    'scaling'  : Vector((1.0, 1.0, 1.0))*deltaX/2, 
                    'location' : Vector((0,0,0)),
                    'material' : checkBoardMaterialsList[0],
                  };
    indentation = 0.09;

    for ix in list(range(-N,N+1)):
      for iy in list(range(-N,N+1)):
        # Retrieve the tileObject that is to be dimpled
        tileObjectName     = 'floorTileAt({0:1d},{1:2d})'.format(ix,iy);
        theTile            = bpy.data.objects[tileObjectName];
        # Generate the sphere object that is to be used to bore out material from the tile
        theSphere          = scene.addSphere(sphereParams);
        theSphere.location = theTile.location + Vector((0,0,deltaX/2*(1-indentation)));
        # Do the carving
        scene.boreOut(theTile, theSphere, True);


  # The Cylinder
  cylinderWidth  = 6.2;
  cylinderHeight = 11;
  # Generate dictionary with properties of the cylinder's outer shell
  params = {'name'    : 'The cylinder',
            'scaling' : Vector((cylinderWidth, cylinderWidth, cylinderHeight)),
            'rotation': Vector((0,0,0)), 
            'location': Vector((-9.4, 9.4, cylinderHeight/2+boardThickness)),
            'material': cylinderMaterialType,
            }; 
  # Add the cylinder (outer shell)
  theCylinder = scene.addCylinder(params);

  deltaHeight     = 1.4;
  cylinderWidth  *= 0.85;
  cylinderHeight -= deltaHeight;
  # Generate dictionary with properties of the cylinder core 
  params = {'name'     : 'The cylinder core',
            'scaling'  : Vector((cylinderWidth, cylinderWidth, cylinderHeight)),
            'rotation' : Vector((0,0,0)), 
            'location' : Vector((-9.4, 9.4, cylinderHeight/2 + deltaHeight+boardThickness)),
            'material' : cylinderMaterialType,
          }; 
  # Generate the cylinder core
  theCylinderCore = scene.addCylinder(params);

  # Carve the cylinder core from the external shell
  scene.boreOut(theCylinder, theCylinderCore, True);



  # The cloth
  # Generate an elevation map representing a creased cloth-like material.
  xBinsNum = 501;  
  yBinsNum = 501;
  elevationMap = SceneUtilsV1.createRandomGaussianBlobsMap(xBinsNum, yBinsNum);

  # Generate dictionary with properties of the cloth object
  params = {'name'         : 'The Cloth',
            'scale'        : Vector((boardHalfWidth*4.0, boardHalfWidth*4.0, boardThickness*.4)),
            'rotation'     : Vector((0,0,0)),
            'location'     : Vector((0,0, 0.05)), 
            'xBinsNum'     : xBinsNum,
            'yBinsNum'     : yBinsNum,
            'elevationMap' : elevationMap,
            'material'     : clothMaterialType,
         };
  # Add the cloth object
  theCloth = scene.addElevationMapObject(params);


  # The enclosing room
  # Generate dictionary with properties of the enclosing room
  params = {'floorName'             : 'floor',
            'backWallName'          : 'backWall',
            'frontWallName'         : 'frontWall',
            'leftWallName'          : 'leftWall',
            'rightWallName'         : 'rightWall',
            'ceilingName'           : 'ceiling',
            'floorMaterialType'     : roomMaterialType,
            'backWallMaterialType'  : roomMaterialType,
            'frontWallMaterialType' : roomMaterialType,
            'leftWallMaterialType'  : roomMaterialType,
            'rightWallMaterialType' : roomMaterialType,
            'ceilingMaterialType'   : roomMaterialType,
            'roomWidth'     : 180,
            'roomDepth'     : 180,
            'roomHeight'    : 100,
            'roomLocation'  : Vector((0,0,0))
            };
  # Add the enclosing room
  scene.addRoom(params);

    
  # Finally, export the scene to a collada file
  scene.exportToColladaFile(sceneParams['exportsDirectory']);



# -------------------------  main() -------------------------------

# Make the dimpled checkerboard version
sceneParams = { 'boardIsDimpled'   : True,
                'sceneName'        : 'CheckerShadowDimples',
                'exportsDirectory' : '/Users/Shared/Matlab/Toolboxes/RenderToolbox3/ExampleScenes/BlenderPythonGeneratedScene',
                'toolboxDirectory' : '/Users/Shared/Matlab/Toolboxes/RenderToolbox3/BlenderPythonSceneUtils'
             };
makeShadowCheckerScene(sceneParams);


# Make the non-dimpled checkerboard version
sceneParams['boardIsDimpled'] = False;
sceneParams['sceneName']      = 'CheckerShadowNoDimples';
makeShadowCheckerScene(sceneParams);




