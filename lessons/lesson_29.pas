{$reference Tao.FreeGlut.dll}
{$reference Tao.OpenGl.dll}
{$reference System.Drawing.dll}

uses
  System, System.Collections.Generic, System.Linq, System.Text, 
  Tao.OpenGl, Tao.FreeGlut,
  System.Drawing, System.Drawing.Imaging;

// Функции для работы с курсором    
function SetCursorPos(x, y: integer): boolean; external 'user32.dll';
function GetCursorPos(var pt: System.Drawing.Point): boolean; external 'user32.dll';
function ShowCursor(bShow: boolean): integer; external 'user32.dll';

//****************************************************// 
//********         Описание вектора         **********//
//****************************************************//   
type
  Vector3D = record
    X, Y, Z: real;
  end;

//****************************************************// 
//********            Класс камеры          **********//
//****************************************************//  
type
  Camera = class
  private 
    mPos: Vector3D;     // Вектор позиции камеры 
    mView: Vector3D;    // Направление, куда смотрит камера 
    mUp: Vector3D;      // Вектор направления вверх
    mStrafe: Vector3D;  // Вектор для стрейфа (движения влево и вправо) камеры
    
    SCREEN_WIDTH, SCREEN_HEIGHT: integer;  // размеры окна
    PosWinX, PosWinY: integer;    // положение окна на мониторе
    middleX, middleY: integer;    // текущее положение курсора 
    currentRotX, lastRotX: real;  // текущий и последний угол вращения
    angleY, angleZ: real; 
    
    mousePos: Point;
    
    //--------------------------------------------------------------
    // Перпендикулярный вектор от двух переданных векторов
    //--------------------------------------------------------------
    function Cross(vVector1, vVector2: Vector3D): Vector3D;
    var
      vNormal: Vector3D;
    begin
      // Если у нас есть 2 вектора (вектор взгляда и вертикальный вектор), 
      // У нас есть плоскость, от которой мы можем вычислить угол в 90 градусов. 
      // Рассчет cross'a прост, но его сложно запомнить с первого раза. 
      // Значение X для вектора = (V1.y * V2.z) - (V1.z * V2.y) 
      vNormal.x := ((vVector1.y * vVector2.z) - (vVector1.z * vVector2.y)); 
      vNormal.y := ((vVector1.z * vVector2.x) - (vVector1.x * vVector2.z)); 
      vNormal.z := ((vVector1.x * vVector2.y) - (vVector1.y * vVector2.x)); 
      
      result := vNormal; 
    end;
    
    //--------------------------------------------------------------
    // Возвращает величину вектора 
    //--------------------------------------------------------------
    function Magnitude(vNormal: Vector3D): real;
    begin
      // Даёт величину нормали, т.е. длину вектора. 
      // Мы используем эту информацию для нормализации вектора.
      result := Math.Sqrt((vNormal.x * vNormal.x) + 
               (vNormal.y * vNormal.y) + (vNormal.z * vNormal.z)); 
    end;
    
    //--------------------------------------------------------------
    // Возвращает нормализированный вектор
    //--------------------------------------------------------------
    function Normalize(vVector: Vector3D): Vector3D;
    var
      magnit: real;
    begin
      // Вектор нормализирован - значит, его длинна равна 1. Например, 
      // вектор (2, 0, 0) после нормализации будет (1, 0, 0). 
      
      // Вычислим величину нормали 
      magnit := Magnitude(vVector); 
      
      // Теперь у нас есть величина, и мы можем разделить наш вектор на его величину. 
      // Это сделает длинну вектора равной единице, так с ним будет легче работать.
      vVector.x := vVector.x / magnit; 
      vVector.y := vVector.y / magnit; 
      vVector.z := vVector.z / magnit; 
      
      result := vVector; 
    end;
  
  //--------------------------------------------------------------   
  public 
    
    //--------------------------------------------------------------
    //  Конструктор 
    //--------------------------------------------------------------
    constructor Create(WIDTH, HEIGHT, posX, posY: integer);
    begin
      SCREEN_HEIGHT := HEIGHT;
      SCREEN_WIDTH := WIDTH;
      currentRotX := 0.0;
      lastRotX := 0.0;
      PosWinX := posX;
      PosWinY := posY;
      
      mousePos := new Point(PosWinX + (SCREEN_WIDTH div 2), PosWinY + (SCREEN_HEIGHT div 2));
    end;
    
    //--------------------------------------------------------------
    // Установить позицию камеры
    //--------------------------------------------------------------
    procedure Position_Camera(pos_x, pos_y, pos_z, view_x, view_y, view_z, 
                                                   up_x, up_y, up_z: real);
    begin
      // Позиция камеры 
      mPos.x := pos_x;      
      mPos.y := pos_y; 
      mPos.z := pos_z; 
      
      // Куда смотрит, т.е. взгляд
      mView.x := view_x; 
      mView.y := view_y; 
      mView.z := view_z;
      
      // Вертикальный вектор камеры
      mUp.x := up_x;
      mUp.y := up_y;
      mUp.z := up_z; 
    end;
    
    //--------------------------------------------------------------
    // Вращение камеры вокруг своей оси (от первого лица)
    //--------------------------------------------------------------
    procedure Rotate_View(speed: real);
    var
      vVector: Vector3D;
    begin
      // Полчим вектор взгляда 
      vVector.x := mView.x - mPos.x; 
      vVector.y := mView.y - mPos.y; 
      vVector.z := mView.z - mPos.z; 
      
      mView.z := (mPos.z + Math.Sin(speed) * vVector.x + Math.Cos(speed) * vVector.z);
      mView.x := (mPos.x + Math.Cos(speed) * vVector.x - Math.Sin(speed) * vVector.z); 
    end;
    
    
    //--------------------------------------------------------------
    // Вращение камеры вокруг своей оси (от первого лица)
    //--------------------------------------------------------------
    procedure Rotate_View(angle, x, y, z: real);
    var
      vView, vNewView: Vector3D;
      cosTheta, sinTheta: real;
    begin
      // Получим наш вектор взгляда (направление, куда мы смотрим)
      vView.x := mView.x - mPos.x;	// направление по X
      vView.y := mView.y - mPos.y;	// направление по Y
      vView.z := mView.z - mPos.z;	// направление по Z
      
 	    // Рассчитаем 1 раз синус и косинус переданного угла
      cosTheta := Math.Cos(angle);
      sinTheta := Math.Sin(angle);
      
 	    // Найдем новую позицию X для вращаемой точки
      vNewView.x := (cosTheta + (1 - cosTheta) * x * x) * vView.x;
      vNewView.x += ((1 - cosTheta) * x * y - z * sinTheta)	* vView.y;
      vNewView.x += ((1 - cosTheta) * x * z + y * sinTheta)	* vView.z;
      
 	    // Найдем позицию Y
      vNewView.y := ((1 - cosTheta) * x * y + z * sinTheta)	* vView.x;
      vNewView.y += (cosTheta + (1 - cosTheta) * y * y)	* vView.y;
      vNewView.y += ((1 - cosTheta) * y * z - x * sinTheta)	* vView.z;
      
 	    // И позицию Z
      vNewView.z := ((1 - cosTheta) * x * z - y * sinTheta)	* vView.x;
      vNewView.z += ((1 - cosTheta) * y * z + x * sinTheta)	* vView.y;
      vNewView.z += (cosTheta + (1 - cosTheta) * z * z)	* vView.z;
      
 	    // Установливаем новый взгляд камеры
      mView.x := mPos.x + vNewView.x;
      mView.y := mPos.y + vNewView.y;
      mView.z := mPos.z + vNewView.z;	
    end;
    
    
    //--------------------------------------------------------------
    // Перемещение камеры (вперед и назад)
    //--------------------------------------------------------------
    procedure Move_Camera(speed: real);
    var
      vVector: Vector3D;
    begin
      // Получаем вектор взгляда 
      vVector.x := mView.x - mPos.x; 
      vVector.y := mView.y - mPos.y; 
      vVector.z := mView.z - mPos.z; 
      
      vVector.y := 0.0;  // Это запрещает камере подниматься вверх 
      vVector := Normalize(vVector); 
      
      mPos.x += vVector.x * speed; 
      mPos.z += vVector.z * speed; 
      mView.x += vVector.x * speed; 
      mView.z += vVector.z * speed; 
    end;
    
    //--------------------------------------------------------------
    // Перемещение камеры (влево и вправо)
    //--------------------------------------------------------------
    procedure Strafe(speed: real);
    begin
      // добавим вектор стрейфа к позиции 
      mPos.x += mStrafe.x * speed; 
      mPos.z += mStrafe.z * speed; 
      
      // Добавим теперь к взгляду 
      mView.x += mStrafe.x * speed; 
      mView.z += mStrafe.z * speed; 
    end;
    
    //--------------------------------------------------------------
    // Перемещение вверх и вниз
    //--------------------------------------------------------------
    procedure upDown(speed: real);
    begin
      mPos.y += speed; 
      mView.y += speed;       
    end;
    
    //--------------------------------------------------------------
    // Вращение вверх и вниз
    //--------------------------------------------------------------
    procedure upDownAngle(speed: real);
    var
      vVector: Vector3D;
    begin
      // Полчим вектор взгляда 
      vVector.x := mView.x - mPos.x; 
      vVector.y := mView.y - mPos.y; 
      vVector.z := mView.z - mPos.z; 
      mView.y += speed; 
    end;
    
    //--------------------------------------------------------------
    // Добавим ф-ю управления взглядом с пом. мышки
    //--------------------------------------------------------------
    procedure SetViewByMouse();
    var
      vAxis: Vector3D;
    begin
      middleX := PosWinX + SCREEN_WIDTH div 2;	// Вычисляем половину ширины
      middleY := PosWinY + SCREEN_HEIGHT div 2;	// И половину высоты экрана
      
      angleY := 0.0;	// Направление взгляда вверх/вниз
      angleZ := 0.0;	// Значение, необходимое для вращения влево-вправо (по оси Y)
      
      
      ShowCursor(false);
      
 	    // Получаем текущие коорд. мыши	        
      GetCursorPos(mousePos);   
      
 	    // Если курсор остался в том же положении, мы не вращаем камеру
      if not ((mousePos.x = middleX) and (mousePos.y = middleY)) then begin
        
   	    // Теперь, получив координаты курсора, возвращаем его обратно в середину.
        SetCursorPos(middleX, middleY);
        
   	    // Теперь нам нужно направление (или вектор), куда сдвинулся курсор.
   	    // Его рассчет - простое вычитание. Просто возьмите среднюю точку и вычтите из неё
   	    // новую позицию мыши: VECTOR = P1 - P2; где P1 - средняя точка (400,300 при 800х600).
   	    // После получения дельты X и Y (или направления), я делю значение 
   	    // на 1000, иначе камера будет жутко быстрой.
        
        angleY := (middleX - mousePos.x) / 1000.0;
        angleZ := (middleY - mousePos.y) / 1000.0;
        lastRotX := currentRotX;		// Сохраняем последний угол вращения 
        
   	    // Если текущее вращение больше 1 градуса, обрежем его, чтобы не вращать слишком быстро
        if (currentRotX > 1.0) then
        begin
          currentRotX := 1.0;
          
    		    // врощаем на оставшийся угол
          if(not (lastRotX = 1.0)) then
          begin
     			    // Чтобы найти ось, вокруг которой вращаться вверх и вниз, нужно 
     			    // найти вектор, перпендикулярный вектору взгляда камеры и 
     			    // вертикальному вектору.
     			    // Это и будет наша ось. И прежде чем использовать эту ось, 
     			    // неплохо бы нормализовать её.
            
            var vVecTemp: Vector3D;
            vVecTemp.x := mView.x - mPos.x; 
            vVecTemp.y := mView.y - mPos.y; 
            vVecTemp.z := mView.z - mPos.z; 
            
            vAxis := Cross(vVecTemp, mUp);
            vAxis := Normalize(vAxis);
            
     			    // Вращаем камеру вокруг нашей оси на заданный угол
            Rotate_View(1.0 - lastRotX, vAxis.x, vAxis.y, vAxis.z);
          end;
        end
        
   	    // Если угол меньше -1.0f, убедимся, что вращение не продолжится
        else if(currentRotX < -1.0) then
        begin
          currentRotX := -1.0;
          if not (lastRotX = -1.0) then
          begin
            var vVecTemp: Vector3D;
            vVecTemp.x := mView.x - mPos.x; 
            vVecTemp.y := mView.y - mPos.y; 
            vVecTemp.z := mView.z - mPos.z; 
            vAxis := Cross(vVecTemp, mUp);
            vAxis := Normalize(vAxis);
            Rotate_View(-1.0 - lastRotX, vAxis.x, vAxis.y, vAxis.z);
          end;
        end
        
   	    // Если укладываемся в пределы 1.0f -1.0f - просто вращаем
         else
        begin
          var vVecTemp: Vector3D;
          vVecTemp.x := mView.x - mPos.x; 
          vVecTemp.y := mView.y - mPos.y; 
          vVecTemp.z := mView.z - mPos.z; 
          vAxis := Cross(vVecTemp, mUp);
          vAxis := Normalize(vAxis);
          Rotate_View(angleZ, vAxis.x, vAxis.y, vAxis.z);
        end;
        
   	    // Всегда вращаем камеру вокруг Y-оси
        Rotate_View(angleY, 0, 1, 0);
      end;
    end;
    
    
    
    //--------------------------------------------------------------
    // Установка камеры 
    //--------------------------------------------------------------
    procedure Look();
    begin
      Glu.gluLookAt(mPos.x, mPos.y, mPos.z, // Ранее упомянутая команда 
                    mView.x, mView.y, mView.z, 
                    mUp.x, mUp.y, mUp.z); 
    end;
    
    //--------------------------------------------------------------
    // Обновление 
    //--------------------------------------------------------------
    procedure update();
    var
      vCross: Vector3D;
    begin
      var vVecTemp: Vector3D;
      vVecTemp.x := mView.x - mPos.x; 
      vVecTemp.y := mView.y - mPos.y; 
      vVecTemp.z := mView.z - mPos.z; 
      
      vCross := Cross(vVecTemp, mUp);
      
      // Нормализуем вектор стрейфа 
      mStrafe := Normalize(vCross); 
      
      // Посмотрим, двигалась ли мыша
      SetViewByMouse();
    end;
    
    //--------------------------------------------------------------
       // Возвращает позицию камеры по Х
       //--------------------------------------------------------------
    function getPosX: real;
    begin
      Result := mPos.x; 
    end;
    
    //--------------------------------------------------------------
    // Возвращает позицию камеры по Y
    //--------------------------------------------------------------
    function getPosY(): real;
    begin
      Result := mPos.y; 
    end;
    
    //--------------------------------------------------------------
    // Возвращает позицию камеры по Z
    //--------------------------------------------------------------
    function getPosZ(): real;
    begin
      Result := mPos.z; 
    end;
    
    //--------------------------------------------------------------
       // Возвращает позицию взгляда по Х
       //--------------------------------------------------------------    
    function getViewX(): real;
    begin
      Result := mView.x; 
    end;
    
    //--------------------------------------------------------------
    // Возвращает позицию взгляда по Y
    //--------------------------------------------------------------
    function getViewY(): real;
    begin
      Result := mView.y; 
    end;
    
    //--------------------------------------------------------------
    // Возвращает позицию взгляда по Z
    //--------------------------------------------------------------
    function getViewZ(): real;
    begin
      Result := mView.z; 
    end;
  
  
  end;//END CLASS
//----------------------------------------------

const
  Key_W = 119; 
  Key_S = 115;
  Key_A = 97;
  Key_D = 100;
  Key_Q = 113;
  Key_E = 101;
  Key_Z = 122;
  Key_X = 120;
  
  Key_ESC = 27;

const
  Width = 600;
  Height = 480;
  
const
  MapSize = 257;  

var
  posX: single := 0.0;
  posY: single := 0.0;
  posZ: single := 10.0;
  rotY: single := 0.0;
  q : integer := 1;
  
  Texture: integer;
  Texture2: integer;
  Texture3: integer;
  
  HeightMap : array[,] of byte;
  
  Cam: Camera;

//****************************************************// 
//*******      Процедура создания куба      **********//
//****************************************************// 
procedure DrawCube();
begin
  // front
  GL.glColor3f(1.0, 0.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
  gl.glVertex3f(-2.0, 2.0, 2.0); // 1
  gl.glVertex3f(-2.0, -2.0, 2.0); // 2 
  gl.glVertex3f(2.0, -2.0, 2.0); // 3
  gl.glVertex3f(2.0, 2.0, 2.0); // 4
  GL.glEnd();
  
  // back
  GL.glColor3f(0.0, 1.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
  gl.glVertex3f(-2.0, 2.0, -2.0); // 5
  gl.glVertex3f(-2.0, -2.0, -2.0); // 6
  gl.glVertex3f(2.0, -2.0, -2.0); // 7
  gl.glVertex3f(2.0, 2.0, -2.0); // 8
  GL.glEnd();
  
  // left
  GL.glColor3f(0.0, 0.0, 1.0);
  GL.glBegin(GL.GL_QUADS);
  gl.glVertex3f(-2.0, 2.0, -2.0); // 5
  gl.glVertex3f(-2.0, -2.0, -2.0); // 6
  gl.glVertex3f(-2.0, -2.0, 2.0); // 2 
  gl.glVertex3f(-2.0, 2.0, 2.0); // 1
  GL.glEnd();
  
  // right
  GL.glColor3f(1.0, 1.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
  gl.glVertex3f(2.0, -2.0, -2.0); // 7
  gl.glVertex3f(2.0, 2.0, -2.0); // 8
  gl.glVertex3f(2.0, 2.0, 2.0); // 4    
  gl.glVertex3f(2.0, -2.0, 2.0); // 3
  GL.glEnd();
  
  // top
  GL.glColor3f(1.0, 0.0, 1.0);
  GL.glBegin(GL.GL_QUADS);
  gl.glVertex3f(-2.0, 2.0, 2.0); // 1
  gl.glVertex3f(2.0, 2.0, 2.0); // 4    
  gl.glVertex3f(2.0, 2.0, -2.0); // 8
  gl.glVertex3f(-2.0, 2.0, -2.0); // 5
  GL.glEnd();
  
  // down
  GL.glColor3f(0.5, 0.0, 0.5);
  GL.glBegin(GL.GL_QUADS);
  gl.glVertex3f(2.0, -2.0, 2.0); // 3
  gl.glVertex3f(-2.0, -2.0, 2.0); // 2  
  gl.glVertex3f(-2.0, -2.0, -2.0); // 6
  gl.glVertex3f(2.0, -2.0, -2.0); // 7
  GL.glEnd();
end;

procedure MYQUAD(Tex: integer);
begin
  Gl.glBindTexture(Gl.GL_TEXTURE_2D, Tex);
  GL.glBegin(GL.GL_QUADS);
  Gl.glTexCoord2f(0, 0); gl.glVertex3f(-2.0, 2.0, 0.0); // 1
  Gl.glTexCoord2f(0, 1); gl.glVertex3f(-2.0, -2.0, 0.0); // 2 
  Gl.glTexCoord2f(1, 1); gl.glVertex3f(2.0, -2.0, 0.0); // 3
  Gl.glTexCoord2f(1, 0); gl.glVertex3f(2.0, 2.0, 0.0); // 4
  GL.glEnd();
end;

//****************************************************// 
//********         Загрузка текстуры        **********//
//****************************************************//
// BMP, GIF, EXIG, JPG, PNG и TIFF
function LoadTextere(filename: string): integer;
var
  texID: integer;
begin
  var img: Bitmap := new Bitmap(filename);
  var rect: Rectangle := new Rectangle(0, 0, img.Width, img.Height);
  var img_data: BitmapData := img.LockBits(rect, ImageLockMode.ReadOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
  
  Gl.glGenTextures(1, texID); 
  WriteLn(texID);
  
  Gl.glBindTexture(Gl.GL_TEXTURE_2D, texID);
  
  Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_WRAP_S, Gl.GL_CLAMP);
  Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_WRAP_T, Gl.GL_CLAMP);
  
  var nMaxAnisotropy: integer := 0;
  Gl.glGetIntegerv(Gl.GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, nMaxAnisotropy); 
  WriteLn('Max ANISOTROPY:', nMaxAnisotropy);
  
  if (nMaxAnisotropy > 0) then
    Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_MAX_ANISOTROPY_EXT, nMaxAnisotropy);
  
  
  Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_MIN_FILTER, Gl.GL_LINEAR_MIPMAP_LINEAR);
  Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_MAG_FILTER, Gl.GL_LINEAR);
  
  Gl.glTexImage2D(Gl.GL_TEXTURE_2D, 0, Gl.GL_RGBA, img_data.Width, img_data.Height, 0, Gl.GL_BGRA, Gl.GL_UNSIGNED_BYTE, img_data.Scan0);
  Gl.glGenerateMipmapEXT(Gl.GL_TEXTURE_2D);
  
  //Glu.gluBuild2DMipmaps (Gl.GL_TEXTURE_2D, Gl.GL_RGBA, img_data.Width, img_data.Height, Gl.GL_BGRA, Gl.GL_UNSIGNED_BYTE, img_data.Scan0);
  
  img.UnlockBits(img_data);
  
  Result := texID;
end;


//****************************************************// 
//****       Загрузка карты высот из текстуры     ****//
//****************************************************//
procedure LoadHeightMap( filename : string; var pHeightMap : array [,] of byte);
var
 img : Bitmap;
 i, j : integer;
 Col : Color; 
begin
  pHeightMap := new byte[ MapSize, MapSize];
  img := new Bitmap (Image.FromFile(filename));
  
  for i:=1 to img.Width-1 do
    for j:=1 to img.Height-1 do begin
      Col := img.GetPixel(i,j);
      pHeightMap[i,j] := (Col.R + Col.G + Col.B) div 3;
    end;
end;


//****************************************************// 
//****       Загрузка карты высот из текстуры     ****//
//****************************************************//
procedure LoadRawFile( filename : string; var pHeightMap : array [,] of byte);
var
 i, j, k : integer;
 ArrRaw : Array of byte;
begin
  k := 1;
  pHeightMap := new byte[ MapSize, MapSize];
  ArrRaw := new byte[ MapSize * MapSize];
  ArrRaw := System.IO.File.ReadAllBytes(filename);
   
  for i:=1 to MapSize-1 do
    for j:=1 to MapSize-1 do begin
      HeightMap[i,j] := ArrRaw[k];
      k := k + 1;
    end;
end;



//****************************************************// 
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************// 
procedure InitScene();
begin
  Writeln(GL.glGetString(GL.GL_VERSION));
  GL.glClearColor(0.0, 0.0, 0.0, 0.0); 
  
  gl.glEnable(gl.GL_DEPTH_TEST);
  
  Gl.glEnable( Gl.GL_TEXTURE_2D );
  Gl.glEnable(Gl.GL_ALPHA_TEST);
  Gl.glAlphaFunc(Gl.GL_GREATER, 0.0); 
  Gl.glEnable(Gl.GL_BLEND);
  Gl.glBlendFunc(Gl.GL_SRC_ALPHA, Gl.GL_ONE_MINUS_SRC_ALPHA);
  Gl.glBlendEquation(Gl.GL_FUNC_ADD);

  
   // Gl.glEnable(Gl.GL_CULL_FACE);
   // Gl.glCullFace(Gl.GL_BACK); 
   // Gl.glFrontFace(Gl.GL_CW);
 //  Gl.glPolygonMode(Gl.GL_FRONT_AND_BACK, Gl.GL_LINE);
  
  
 // Texture := LoadTextere('data\a2.png');
 // Texture2 := LoadTextere('data\tex1.jpg');
  
  Texture3 := LoadTextere('data\terrain\ter2\terrain2.jpg');
  
  
  //LoadHeightMap('data\terrain\ter3\heightMap2.jpg',HeightMap);
  LoadRawFile('data\terrain\ter2\heightMap.raw',HeightMap);
  
  
  // Создание камеры и задание первоначальных значений
  Cam := new Camera(Width, Height, 300, 200);
  Cam.Position_Camera(0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
end;


//****************************************************// 
//***               Создание плейна                ***//
//****************************************************// 
procedure DrawPlane();
var
  i, j: integer;
  x, y, z : real;
  zoom : real;
begin
  zoom := 0.5;
  Gl.glPushMatrix(); 
  for i := 1 to 120 do 
    for j := 1 to 30 do 
    begin
      x := i * zoom;
      z := j * zoom;
      y := -1;    
     Gl.glBegin(Gl.GL_TRIANGLE_STRIP);
       Gl.glVertex3f(x,y,z);
       Gl.glVertex3f(x+zoom, y, z);
       Gl.glVertex3f(x, y, z + zoom);
       Gl.glVertex3f(x + zoom, y, z + zoom);
     Gl.glEnd;  
    end;
  Gl.glPopMatrix(); 
end;

//****************************************************// 
//***               Создание sin(x)                ***//
//****************************************************// 
procedure DrawSinX();
var
  i, j: integer;
  x, y1, y2, z : real;
  zoom : real;
begin
  zoom := 0.5;
  Gl.glPushMatrix(); 
  for i := 1 to 120 do 
    for j := 1 to 30 do 
    begin
      x := i * zoom;
      z := j * zoom;
      y1 := Math.sin((i-1)*zoom) ; 
      y2 := Math.sin((i) * zoom) ;
      
     Gl.glBegin(Gl.GL_TRIANGLE_STRIP);
       Gl.glVertex3f(x,y1,z);
       Gl.glVertex3f(x+zoom, y2, z);
       Gl.glVertex3f(x, y1, z + zoom);
       Gl.glVertex3f(x + zoom, y2, z + zoom);
     Gl.glEnd;  
    end;
  Gl.glPopMatrix(); 
  
end;

//****************************************************// 
//***               Anim sin(x)                    ***//
//****************************************************// 
procedure DrawSinXAnim();
var
  i, j: integer;
  x, y1, y2, z : real;
  zoom : real;
begin
  zoom := 0.5;
  Gl.glPushMatrix(); 
  for i := 1 to 120 do 
    for j := 1 to 30 do 
    begin
      x := i * zoom;
      z := j * zoom;
      y1 := Math.sin((q+i-1)*zoom) ; 
      y2 := Math.sin((q+i) * zoom) ;
      
     Gl.glBegin(Gl.GL_TRIANGLE_STRIP);
       Gl.glVertex3f(x,y1,z);
       Gl.glVertex3f(x+zoom, y2, z);
       Gl.glVertex3f(x, y1, z + zoom);
       Gl.glVertex3f(x + zoom, y2, z + zoom);
     Gl.glEnd;  
    end;
  Gl.glPopMatrix(); 
  
    q := q +1;
  if (q > 100) then q := 1;
  
end;


//****************************************************// 
//***               Создание террейна              ***//
//****************************************************// 
procedure DrawTerrain( tex: integer );
var
  i, j: integer;
  x, y, z, h : real;
  zoom : real;
  TexMap : real;
begin
  zoom := 10.0;
  h := 5.0 / zoom;
  TexMap := 1.0 / MapSize;
  
  Gl.glPushMatrix(); 
  Gl.glBindTexture(Gl.GL_TEXTURE_2D, tex);
  for i := 1 to MapSize-2 do 
    for j := 1 to MapSize-2  do 
    begin
      x := i * zoom;
      z := j * zoom;
    
     Gl.glBegin(Gl.GL_TRIANGLE_STRIP);
      
       Gl.glTexCoord2f(i * TexMap, j * TexMap);
       Gl.glVertex3f(x, HeightMap[i,j] / h, z);
       
       Gl.glTexCoord2f((i+1) * TexMap, j * TexMap);
       Gl.glVertex3f(x+zoom, HeightMap[i+1,j] / h, z);
       
       Gl.glTexCoord2f(i * TexMap, (j+1) * TexMap);
       Gl.glVertex3f(x, HeightMap[i,j+1] / h, z + zoom);
       
       Gl.glTexCoord2f((i+1) * TexMap, (j+1) * TexMap);
       Gl.glVertex3f(x + zoom, HeightMap[i+1,j+1] / h, z + zoom);
     Gl.glEnd;  
     
    end;
  Gl.glPopMatrix(); 
end;


//****************************************************// 
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************// 
procedure RenderScene();
begin
  GL.glLoadIdentity();
  GL.glClear(GL.GL_COLOR_BUFFER_BIT or GL.GL_DEPTH_BUFFER_BIT);
  
  Cam.Look();

  Gl.glPushMatrix(); 
   // DrawPlane;
   // DrawSinX;
   //DrawSinXAnim;
  Gl.glTranslatef(0.0,-10.0,0.0); 
   DrawTerrain( Texture3 );
  Gl.glPopMatrix(); 
  
  Cam.update(); 

  Glut.glutSwapBuffers;
end;

//****************************************************// 
//*** Процедура таймер.                            ***//
//*** Вызывается каждые 40 мсек для отрисовка кадра **//
//****************************************************// 
procedure Timer(val: integer);
begin
  Glut.glutPostRedisplay();
  Glut.glutTimerFunc(40, Timer, 0);
end;

//****************************************************// 
//***  Процедура перенастройки                     ***//
//***  Проц. вызыв. при изменении размера экрана   ***//
//****************************************************//
procedure Reshape(w, h: integer);
begin
  
  gl.glViewport(0, 0, w, h);
  gl.glMatrixMode(gl.GL_PROJECTION);
  gl.glLoadIdentity();
  glu.gluPerspective(45, w / h, 0.1, 10000.0); 
  gl.glMatrixMode(gl.GL_MODELVIEW);
  gl.glLoadIdentity();
  
end;

procedure pressKey(key: byte; x, y: integer);
begin
  case key of
    Key_W: Cam.Move_Camera(10.0);
    Key_S: Cam.Move_Camera(-10.0);
    Key_A: Cam.Strafe(-10.0);
    Key_D: Cam.Strafe(10.0);
    // Key_Q  : Cam.Rotate_View(-0.05); 
    // Key_E  : Cam.Rotate_View( 0.05);
    Key_Z: Cam.upDown(-10.0);
    Key_X: Cam.upDown(10.0);
    
    Key_ESC: glut.glutLeaveMainLoop(); 
  else writeln(key);
  end; 
end;


begin
  Glut.glutInit(); 
  Glut.glutInitWindowSize(Width, Height);
  Glut.glutInitWindowPosition(300, 200); 
  Glut.glutInitDisplayMode(GLUT.GLUT_RGBA or Glut.GLUT_DOUBLE or GLUT.GLUT_DEPTH);
  Glut.glutCreateWindow('Tao Example');  
  
  //Glut.glutGameModeString(':32'); 
  //if ( Glut.glutGameModeGet( Glut.GLUT_GAME_MODE_POSSIBLE) <> 0 )
  // then Glut.glutEnterGameMode()
  // else Glut.glutLeaveGameMode();
  
  Glut.glutDisplayFunc(RenderScene);
  Glut.glutReshapeFunc(Reshape);
  Glut.glutTimerFunc(40, Timer, 0);
  
  glut.glutKeyboardFunc(pressKey);
  
  InitScene();
  Glut.glutMainLoop();
end.
