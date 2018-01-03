{ Simple demo how to write a 3D DXF File. }
program WrlToDXF;




uses SysUtils, CastleVectors, CastleSceneCore, CastleShapes, CastleTriangles,
  CastleFilesUtils,classes,strutils,X3DTriangles,X3DNodes,dxf3dutilsCGE;







var
Scene: TCastleSceneCore;
sDXFFileName : string;
sFileName : string;



{$R *.res}

begin
  Scene := TCastleSceneCore.Create(nil);
  try

   // define how Box Cylinder is split to Triangles
  DefaultTriangulationSlices := 18;
  DefaultTriangulationStacks := 6;
  DefaultTriangulationDivisions := 0;


  sFileName := ApplicationData('mist.wrl');

  if fileexists(paramstr(1)) then
    sFileName := paramstr(1)
  else
    begin
    writeln('First parameter must be a .wrl or .x3d or .obj file');
    exit;
    end;

  if paramstr(2) = '' then
    sDXFFileName := changefileext(sFileName,'.dxf')
  else
    sDXFFileName := paramstr(2);




  Scene.Load(sFileName);


  dxf3dUtils := Tdxf3dUtils.create(Scene);
  try
  dxf3dUtils.execute(sDXFFileName);
  finally
  FreeAndNil(dxf3dUtils);
  end;

//  readln();

  finally FreeAndNil(Scene) end;
end.
