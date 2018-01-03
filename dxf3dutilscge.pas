unit dxf3dutilsCGE;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, strutils,contnrs,
  CastleVectors,
  X3DNodes,
  X3DFields,
  CastleShapes,
  CastleSceneCore,
  X3DTriangles,
  CastleGeometryArrays,
  CastleTriangles;


type

    TTriangleHandler = class
    procedure HandleTriangle(Shape: TObject;
      const Position: TTriangle3Single;
      const Normal: TTriangle3Single; const TexCoord: TTriangle4Single;
      const Face: TFaceIndex);
  end;

  { TdxfColor }

  TdxfColor = class(TObject)
    public
    iNrDXF : integer;
    iRed : integer;
    iGreen : integer;
    iBlue : integer;
    function calculateColorDiff(iRed_, iGreen_, iBlue_ : integer) : integer;
  end;

  { TdxfColorList }

  TdxfColorList = class(Tobjectlist)
  private
    procedure AddAllColors;
  public
  procedure addColor(iNrDXF_,iRed_,iGreen_,iBlue_:integer);

  function findColorNrToRGB(iRed_,iGreen_,iBlue_:integer): integer;
  function dxfColor(i:integer) : TdxfColor;

  constructor Create;
  end;

    { TPositionDXF }

  TPositionDXF = class(TObject)
    public
    icolordxf : integer;
    Position: TTriangle3Single;
    Normal: TTriangle3Single;
  end;

  { TPositionDXFList }

  TPositionDXFList = class(Tobjectlist)
  private
  function PositionDXF(i:integer) : TPositionDXF;
  public
  constructor Create;
  end;

 TDXF4Corners =   packed array[0..3] of TVector3Single;

  { Tdxf3dUtils }

  Tdxf3dUtils = class(TObject)

  private
    Scene: TCastleSceneCore;
    sl : TStringlist;
    dxfColorList : TdxfColorList;

    PositionDXFList : TPositionDXFList;

    procedure FillDXFStart();
    procedure FillSlDXF3dFaceEx(DXF4Corners : TDXF4Corners; iColorDXF: integer);
    function floattostrDot(d: single): string;
    function MakeColorDxfFromShapeNode(ShapeNode: TAbstractShapeNode): integer;
    function SameVector(v1, v2: TVector3Single): boolean;
    procedure SetStacksDivisionsForShapeTree(Scene_Shapes: TShapeTree);
    procedure FillSlDXF3dFace(Position: TTriangle3Single;  iColorDXF : integer);
    procedure saveDXFfile(sFilename: string);
    procedure writeTreeangleToDXF;
  public
    Procedure Execute(sDXFFileName : string);
    constructor Create(Scene_:TCastleSceneCore  ) ;
    destructor Destroy; override;
  end;


  var dxf3dUtils : Tdxf3dUtils;





implementation

{ TPositionDXFList }

function TPositionDXFList.PositionDXF(i: integer): TPositionDXF;
begin
result := TPositionDXF(self[i]);
end;

constructor TPositionDXFList.Create;
begin
inherited;
self.OwnsObjects := true;
end;

//Callback Funktion for Triangle
procedure TTriangleHandler.HandleTriangle(Shape: TObject;
  const Position: TTriangle3Single;
  const Normal: TTriangle3Single; const TexCoord: TTriangle4Single;
  const Face: TFaceIndex);
var icolordxf : integer;
begin
//write Triangle to DXF
icolordxf  := dxf3dUtils.MakeColorDxfFromShapeNode(TShape(Shape).Node);
dxf3dUtils.FillSlDXF3dFace( Position,icolordxf );

end;

{ TdxfColor }
//Look for the Color fit to the RGB Value
function TdxfColor.calculateColorDiff(iRed_, iGreen_, iBlue_: integer): integer;
begin
  result := abs( iRed_ - iRed) + abs( iGreen_ - iGreen) + abs( iBlue_ - iBlue);
end;

{ TdxfColorList }

procedure TdxfColorList.addColor(iNrDXF_, iRed_, iGreen_, iBlue_: integer);
var mydxfColor : TdxfColor;
begin
mydxfColor := TdxfColor.create;

mydxfColor.iNrDXF := iNrDXF_;
mydxfColor.iRed := iRed_;
mydxfColor.iGreen := iGreen_;
mydxfColor.iBlue := iBlue_;

self.Add( mydxfColor);

end;
// find Color Nr To RGB
function TdxfColorList.findColorNrToRGB(iRed_, iGreen_, iBlue_: integer  ): integer;
var i,ibest,iDelta,iDeltaMin : integer;
  found : boolean;
begin
result := -1;
iDeltaMin := 999999;
found := false;
ibest := 0;

for i := 0 to self.Count -1 do
  begin
  iDelta := self.dxfColor(i).calculateColorDiff(iRed_, iGreen_, iBlue_);
  if self.dxfColor(i).calculateColorDiff(iRed_, iGreen_, iBlue_) = 0 then
    begin
    result := self.dxfColor(i).iNrDXF;
    found := true;
    break;
    end;
  if iDelta < iDeltaMin then
    begin
    iDeltaMin :=  iDelta;
    ibest := i;
    end;
  end;


if not found then
  result := self.dxfColor(ibest).iNrDXF;

end;

function TdxfColorList.dxfColor(i: integer): TdxfColor;
begin
  result := TdxfColor(self[i]);
end;

constructor TdxfColorList.Create;
begin
inherited;
self.OwnsObjects := true;
end;
// All DXF Colors in a List
Procedure TdxfColorList.AddAllColors;
begin
addColor(1,255,0,0);
addColor(2,255,255,0);
addColor(3,0,255,0);
addColor(4,0,255,255);
addColor(5,0,0,255);
addColor(6,255,0,255);
addColor(7,255,255,255);
addColor(8,128,128,128);
addColor(9,192,192,192);
addColor(10,255,0,0);
addColor(11,255,127,127);
addColor(12,204,0,0);
addColor(13,204,102,102);
addColor(14,153,0,0);
addColor(15,153,76,76);
addColor(16,127,0,0);
addColor(17,127,63,63);
addColor(18,76,0,0);
addColor(19,76,38,38);
addColor(20,255,63,0);
addColor(21,255,159,127);
addColor(22,204,51,0);
addColor(23,204,127,102);
addColor(24,153,38,0);
addColor(25,153,95,76);
addColor(26,127,31,0);
addColor(27,127,79,63);
addColor(28,76,19,0);
addColor(29,76,47,38);
addColor(30,255,127,0);
addColor(31,255,191,127);
addColor(32,204,102,0);
addColor(33,204,153,102);
addColor(34,153,76,0);
addColor(35,153,114,76);
addColor(36,127,63,0);
addColor(37,127,95,63);
addColor(38,76,38,0);
addColor(39,76,57,38);
addColor(40,255,191,0);
addColor(41,255,223,127);
addColor(42,204,153,0);
addColor(43,204,178,102);
addColor(44,153,114,0);
addColor(45,153,133,76);
addColor(46,127,95,0);
addColor(47,127,111,63);
addColor(48,76,57,0);
addColor(49,76,66,38);
addColor(50,255,255,0);
addColor(51,255,255,127);
addColor(52,204,204,0);
addColor(53,204,204,102);
addColor(54,153,153,0);
addColor(55,153,153,76);
addColor(56,127,127,0);
addColor(57,127,127,63);
addColor(58,76,76,0);
addColor(59,76,76,38);
addColor(60,191,255,0);
addColor(61,223,255,127);
addColor(62,153,204,0);
addColor(63,178,204,102);
addColor(64,114,153,0);
addColor(65,133,153,76);
addColor(66,95,127,0);
addColor(67,111,127,63);
addColor(68,57,76,0);
addColor(69,66,76,38);
addColor(70,127,255,0);
addColor(71,191,255,127);
addColor(72,102,204,0);
addColor(73,153,204,102);
addColor(74,76,153,0);
addColor(75,114,153,76);
addColor(76,63,127,0);
addColor(77,95,127,63);
addColor(78,38,76,0);
addColor(79,57,76,38);
addColor(80,63,255,0);
addColor(81,159,255,127);
addColor(82,51,204,0);
addColor(83,127,204,102);
addColor(84,38,153,0);
addColor(85,95,153,76);
addColor(86,31,127,0);
addColor(87,79,127,63);
addColor(88,19,76,0);
addColor(89,47,76,38);
addColor(90,0,255,0);
addColor(91,127,255,127);
addColor(92,0,204,0);
addColor(93,102,204,102);
addColor(94,0,153,0);
addColor(95,76,153,76);
addColor(96,0,127,0);
addColor(97,63,127,63);
addColor(98,0,76,0);
addColor(99,38,76,38);
addColor(100,0,255,63);
addColor(101,127,255,159);
addColor(102,0,204,51);
addColor(103,102,204,127);
addColor(104,0,153,38);
addColor(105,76,153,95);
addColor(106,0,127,31);
addColor(107,63,127,79);
addColor(108,0,76,19);
addColor(109,38,76,47);
addColor(110,0,255,127);
addColor(111,127,255,191);
addColor(112,0,204,102);
addColor(113,102,204,153);
addColor(114,0,153,76);
addColor(115,76,153,114);
addColor(116,0,127,63);
addColor(117,63,127,95);
addColor(118,0,76,38);
addColor(119,38,76,57);
addColor(120,0,255,191);
addColor(121,127,255,223);
addColor(122,0,204,153);
addColor(123,102,204,178);
addColor(124,0,153,114);
addColor(125,76,153,133);
addColor(126,0,127,95);
addColor(127,63,127,111);
addColor(128,0,76,57);
addColor(129,38,76,66);
addColor(130,0,255,255);
addColor(131,127,255,255);
addColor(132,0,204,204);
addColor(133,102,204,204);
addColor(134,0,153,153);
addColor(135,76,153,153);
addColor(136,0,127,127);
addColor(137,63,127,127);
addColor(138,0,76,76);
addColor(139,38,76,76);
addColor(140,0,191,255);
addColor(141,127,223,255);
addColor(142,0,153,204);
addColor(143,102,178,204);
addColor(144,0,114,153);
addColor(145,76,133,153);
addColor(146,0,95,127);
addColor(147,63,111,127);
addColor(148,0,57,76);
addColor(149,38,66,76);
addColor(150,0,127,255);
addColor(151,127,191,255);
addColor(152,0,102,204);
addColor(153,102,153,204);
addColor(154,0,76,153);
addColor(155,76,114,153);
addColor(156,0,63,127);
addColor(157,63,95,127);
addColor(158,0,38,76);
addColor(159,38,57,76);
addColor(160,0,63,255);
addColor(161,127,159,255);
addColor(162,0,51,204);
addColor(163,102,127,204);
addColor(164,0,38,153);
addColor(165,76,95,153);
addColor(166,0,31,127);
addColor(167,63,79,127);
addColor(168,0,19,76);
addColor(169,38,47,76);
addColor(170,0,0,255);
addColor(171,127,127,255);
addColor(172,0,0,204);
addColor(173,102,102,204);
addColor(174,0,0,153);
addColor(175,76,76,153);
addColor(176,0,0,127);
addColor(177,63,63,127);
addColor(178,0,0,76);
addColor(179,38,38,76);
addColor(180,63,0,255);
addColor(181,159,127,255);
addColor(182,51,0,204);
addColor(183,127,102,204);
addColor(184,38,0,153);
addColor(185,95,76,153);
addColor(186,31,0,127);
addColor(187,79,63,127);
addColor(188,19,0,76);
addColor(189,47,38,76);
addColor(190,127,0,255);
addColor(191,191,127,255);
addColor(192,102,0,204);
addColor(193,153,102,204);
addColor(194,76,0,153);
addColor(195,114,76,153);
addColor(196,63,0,127);
addColor(197,95,63,127);
addColor(198,38,0,76);
addColor(199,57,38,76);
addColor(200,191,0,255);
addColor(201,223,127,255);
addColor(202,153,0,204);
addColor(203,178,102,204);
addColor(204,114,0,153);
addColor(205,133,76,153);
addColor(206,95,0,127);
addColor(207,111,63,127);
addColor(208,57,0,76);
addColor(209,66,38,76);
addColor(210,255,0,255);
addColor(211,255,127,255);
addColor(212,204,0,204);
addColor(213,204,102,204);
addColor(214,153,0,153);
addColor(215,153,76,153);
addColor(216,127,0,127);
addColor(217,127,63,127);
addColor(218,76,0,76);
addColor(219,76,38,76);
addColor(220,255,0,191);
addColor(221,255,127,223);
addColor(222,204,0,153);
addColor(223,204,102,178);
addColor(224,153,0,114);
addColor(225,153,76,133);
addColor(226,127,0,95);
addColor(227,127,63,111);
addColor(228,76,0,57);
addColor(229,76,38,66);
addColor(230,255,0,127);
addColor(231,255,127,191);
addColor(232,204,0,102);
addColor(233,204,102,153);
addColor(234,153,0,76);
addColor(235,153,76,114);
addColor(236,127,0,63);
addColor(237,127,63,95);
addColor(238,76,0,38);
addColor(239,76,38,57);
addColor(240,255,0,63);
addColor(241,255,127,159);
addColor(242,204,0,51);
addColor(243,204,102,127);
addColor(244,153,0,38);
addColor(245,153,76,95);
addColor(246,127,0,31);
addColor(247,127,63,79);
addColor(248,76,0,19);
addColor(249,76,38,47);
addColor(250,51,51,51);
addColor(251,91,91,91);
addColor(252,132,132,132);
addColor(253,173,173,173);
addColor(254,214,214,214);
addColor(255,255,255,255);
end;
//Float to Str with dot for DXF
function Tdxf3dUtils.floattostrDot(d: single):string;
begin
result := ' '+ansireplacestr(floattostr(d) ,DefaultFormatSettings.DecimalSeparator,'.');
end;

//function MemoryStreamToString(M: TMemoryStream): AnsiString;
//begin
//  SetString(Result, PAnsiChar(M.Memory), M.Size);
//end;


procedure Tdxf3dUtils.SetStacksDivisionsForShapeTree( Scene_Shapes :  TShapeTree);
var SI: TShapeTreeIterator;
Geometry : TAbstractX3DGeometryNode;
//BoxNode : TBOXNODE ;
CylinderNode : TCylinderNode ;
myshape : TShape;
//GeometryArrays :TGeometryArrays;

//MFVec3f : TMFVec3f;
//i:integer;
//X3DField : TX3DField;
//writer : TX3DWriter;
//Aversion : TX3DVersion;
//aStream : TMemoryStream;

//mySFVec3f : TSFVec3f;
//mySFNode : TSFNode ;
//S: TX3DGraphTraverseState;
begin
SI := TShapeTreeIterator.Create(Scene_Shapes, true);
while SI.GetNext do
  begin
    myshape := SI.Current;

    if myshape.Node <> nil then
    if myshape.Node.Geometry <> nil then
    if myshape.Node.Geometry  is  TAbstractX3DGeometryNode then
      begin
      Geometry := TAbstractX3DGeometryNode(myshape.Node.Geometry) ;

      if Geometry is TCylinderNode then
        begin
        CylinderNode := TCylinderNode(Geometry);
        CylinderNode.Stacks := 1;    //set Stacks  cylinder to 1 less treeangles better
        end;

     { if Geometry is TBOXNODE then
        begin
        BoxNode := TBOXNODE(Geometry);
        writeln('Box: SIZE '+VectorToNiceStr(BoxNode.Size) );

        GeometryArrays := myshape.GeometryArrays(true) ;
        for i := 0 to  GeometryArrays.count -1 do
         writeln('  Box: Geometrie '+ VectorToNiceStr(GeometryArrays.Position(i)[0])) ;

       for i := 0 to BoxNode.FieldsCount - 1 do
          begin
          //X3DField := BoxNode.Fields[i];
          //writeln(X3DField.NiceName + '  '+X3DField.ClassName );
          //
          //if X3DField is TSFVec3f  then
          //  begin
          //  mySFVec3f := TSFVec3f(X3DField) ;
          //  writeln( VectorToNiceStr(mySFVec3f.Value )  );
          //  end;
          //
          // if X3DField is TSFNode  then
          //  begin
          //  mySFNode := TSFNode(X3DField) ;
          //  writeln(  mySFNode.X3DType  );
          //  end;

          //aStream := TMemoryStream.create;
          //writer := TX3DWriter.Create(aStream,Aversion,xeClassic) ;
          //X3DField.SaveToStream(writer);
          //
          //writeln(MemoryStreamToString(aStream));
          //
          //
          //writer.free;
          //aStream.free;
          //
          //writeln(X3DField.NiceName );
          end;


        //writeln('Box: SIZE '+inttostr(i));

       // BoxNode := TBOXNODE(Geometry);
       // for i := 0 to BoxNode.FieldsCount - 1 do
       //   begin
       //   X3DField := BoxNode.Fields[i];
       //   writeln(X3DField.TypeName);
       //   end;
       //// S := X3DGraphTraverseState(true) ;
       // MFVec3f := BoxNode.Coordinates(S );


      //


        end;  }

      end;
  end;
FreeAndNil(SI);
end;
//Make Color Dxf From Shape Node

function Tdxf3dUtils.MakeColorDxfFromShapeNode(ShapeNode: TAbstractShapeNode):integer;
var
    Material: TMaterialNode;
    ColorRGB: TVector3Single;
begin
Material := nil;
if ShapeNode <> nil then
  Material := ShapeNode.Material;
if Material <> nil then
  begin
  ColorRGB := Material.DiffuseColor;
//  Writeln('Color is ', VectorToNiceStr(ColorRGB));
end
//else
//  Writeln('No material. Shape should be unlit. Or you can use default DiffuseColor = Vector3Single(0.8, 0.8, 0.8).');
;

result := self.dxfColorList.findColorNrToRGB(round(ColorRGB[0] * 256),round(ColorRGB[1]*256) ,round(ColorRGB[2]*256) ) ;


end;
// Add a Triangle to the Position DXF list
procedure Tdxf3dUtils.FillSlDXF3dFace(Position: TTriangle3Single ; iColorDXF : integer);
var myPosition : TPositionDXF;
begin

  myPosition := TPositionDXF.create;
  myPosition.Position := Position ;
  myPosition.icolordxf:= icolordxf;

  dxf3dUtils.PositionDXFList.Add(myPosition);
end;
//write Triangle to string list ( DXF File)
procedure Tdxf3dUtils.FillSlDXF3dFaceEx(DXF4Corners : TDXF4Corners ; iColorDXF : integer);
begin
  sl.add('3DFACE');
  sl.add('8');
  sl.add('NONAME');
  sl.add('62');
  sl.add(inttostr(iColorDXF) );
  sl.add('10');
  sl.add(floattostrDot(DXF4Corners[0][0]) );
  sl.add('20');
  sl.add(floattostrDot((-1)*DXF4Corners[0][2]) );
  sl.add('30');
  sl.add(floattostrDot(DXF4Corners[0][1]) );
  sl.add('11');
  sl.add(floattostrDot(DXF4Corners[1][0]) );
  sl.add('21');
  sl.add(floattostrDot((-1)*DXF4Corners[1][2]) );
  sl.add('31');
  sl.add(floattostrDot(DXF4Corners[1][1]) );
  sl.add('12');
  sl.add(floattostrDot(DXF4Corners[2][0]) );
  sl.add('22');
  sl.add(floattostrDot((-1)*DXF4Corners[2][2]) );
  sl.add('32');
  sl.add(floattostrDot(DXF4Corners[2][1]) );
  sl.add('13');
  sl.add(floattostrDot(DXF4Corners[3][0]) );
  sl.add('23');
  sl.add(floattostrDot((-1)*DXF4Corners[3][2]) );
  sl.add('33');
  sl.add(floattostrDot(DXF4Corners[3][1]));
  sl.add('0');
end;
//Constructor for Main Class,
constructor Tdxf3dUtils.Create(Scene_: TCastleSceneCore);
begin
inherited create;
dxfColorList := TdxfColorList.create;
dxfColorList.AddAllColors;

PositionDXFList := TPositionDXFList.create;

sl := TStringlist.create;
FillDXFStart();

Scene := Scene_;

SetStacksDivisionsForShapeTree( Scene.Shapes) ;
end;
// Execute  write the DXF File to disk
procedure Tdxf3dUtils.Execute(sDXFFileName : string);
var     SI: TShapeTreeIterator;
Handler: TTriangleHandler;
//TriangleInfo: PTriangle;
//i:integer;
begin

//if true then  // for use callback for DXF set this to true
//  begin
   SI := TShapeTreeIterator.Create(Scene.Shapes, true);
   try
     Handler := TTriangleHandler.Create;
     try
       while SI.GetNext do
         begin
         { Try also LocalTriangulate instead of Triangulate,
           to have Position in local shape coordinates. }
         SI.Current.Triangulate(true, @Handler.HandleTriangle);

         self.writeTreeangleToDXF;
         end;
     finally FreeAndNil(Handler) end;
   finally FreeAndNil(SI) end;
//  end
//else
//  begin
//  { An alternative method: use Scene.InternalOctreeVisibleTriangles.Triangles.
//   This is available only when Scene.Spatial contains appropriate flag.
//   This method is useful in larger programs, when besides writing triangles,
//   you want to e.g. render or perform collision detection with the scene.
//   In such case, you will have Scene.InternalOctreeVisibleTriangles
//   created anyway. So you can use it also to get triangles list.    }
//
// Scene.Spatial := Scene.Spatial + [ssVisibleTriangles];
////    Scene.TrianglesCount() .TriangleOctreeLimits^.MaxDepth := 1;
// for I := 0 to Scene.InternalOctreeVisibleTriangles.Triangles.Count - 1 do
// begin
//   TriangleInfo := @(Scene.InternalOctreeVisibleTriangles.Triangles.List^[I]);
//
//   self.FillSlDXF3dFace(TriangleInfo^.World.Triangle,   dxf3dUtils.MakeColorDxfFromShapeNode(TShape(TriangleInfo^.Shape).Node)  );
//   self.writeTreeangleToDXF;
// end;

//  end;


 self.saveDXFfile(sDXFFileName);
end;
//clear Memory
destructor Tdxf3dUtils.Destroy;
begin

FreeAndNil(PositionDXFList);

FreeAndNil(dxfColorList);
FreeAndNil(sl);
inherited;
end;

procedure Tdxf3dUtils.saveDXFfile(sFilename : string);
begin
sl.add('ENDSEC');
sl.add('0');
sl.add('EOF');

sl.SaveToFile(sFilename);
end;

function Tdxf3dUtils.SameVector(v1,v2 : TVector3Single) : boolean;
begin
result := false;

if v1[0] = v2[0] then
  if v1[1] = v2[1] then
    if v1[2] = v2[2] then
      result := true;

end;
// writeTreeangleToDXF if two Triangle on the same side write a rectangle
procedure Tdxf3dUtils.writeTreeangleToDXF;
var i,i2 : integer;
myPosition : TPositionDxf;
myPositionNext : TPositionDxf;
DXF4Corners : TDXF4Corners;
found : boolean;
begin
found := false;
for i := 0 to self.PositionDXFList.Count -1 do
  begin
  if found then
    begin
    found := false;
    continue;
    end;

  myPosition := PositionDXFList.PositionDXF(i);

  DXF4Corners[0][0] := myPosition.Position[0][0];
  DXF4Corners[0][1] := myPosition.Position[0][1];
  DXF4Corners[0][2] := myPosition.Position[0][2];


  DXF4Corners[1][0] := myPosition.Position[1][0];
  DXF4Corners[1][1] := myPosition.Position[1][1];
  DXF4Corners[1][2] := myPosition.Position[1][2];

  DXF4Corners[2][0] := myPosition.Position[2][0];
  DXF4Corners[2][1] := myPosition.Position[2][1];
  DXF4Corners[2][2] := myPosition.Position[2][2];

  DXF4Corners[3][0] := myPosition.Position[2][0];
  DXF4Corners[3][1] := myPosition.Position[2][1];
  DXF4Corners[3][2] := myPosition.Position[2][2];

  //very simple solution if 2 treeangle gives a rectangle, use the rectange  ==> looks better dxf reduce file size
  if i < self.PositionDXFList.Count -1 then
    begin
    myPositionNext := PositionDXFList.PositionDXF(i+1);
    if  SameVector(myPosition.Position[0] , myPositionNext.Position[0] ) then
    if  SameVector(myPosition.Position[2] , myPositionNext.Position[1] ) then
      begin
      DXF4Corners[3][0] := myPositionNext.Position[2][0];
      DXF4Corners[3][1] := myPositionNext.Position[2][1];
      DXF4Corners[3][2] := myPositionNext.Position[2][2];
      found := true;
      end;
    end;


  i2 :=  myPosition.icolordxf;

  FillSlDXF3dFaceEx(DXF4Corners,i2 );

  end;
PositionDXFList.clear;
end;

procedure Tdxf3dUtils.FillDXFStart();
begin
//Start DXF File
sl.add('0');
sl.add('SECTION');
sl.add('2');
sl.add('TABLES');
sl.add('0');
sl.add('TABLE');
sl.add('2');
sl.add('LTYPE');
sl.add('70');
sl.add('1');
sl.add('0');
sl.add('LTYPE');
sl.add('2');
sl.add('CONTINUOUS');
sl.add('70');
sl.add('64');
sl.add('3');
sl.add('Solid line');
sl.add('72');
sl.add('65');
sl.add('73');
sl.add('0');
sl.add('40');
sl.add('0.000000');
sl.add('0');
sl.add('ENDTAB');
sl.add('0');
sl.add('TABLE');
sl.add('2');
sl.add('LAYER');
sl.add('70');
sl.add('1');
sl.add('0');
sl.add('LAYER');
sl.add('2');
sl.add('NONAME');
sl.add('70');
sl.add('0');
sl.add('62');
sl.add('8');
sl.add('6');
sl.add('CONTINUOUS');
sl.add('0');
sl.add('ENDTAB');
sl.add('0');
sl.add('ENDSEC');
sl.add('0');
sl.add('SECTION');
sl.add('2');
sl.add('ENTITIES');
sl.add('0');


end;


end.

