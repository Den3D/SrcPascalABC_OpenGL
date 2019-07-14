{$reference Tao.FreeGlut.dll}
{$reference Tao.OpenGl.dll}
{$reference System.Drawing.dll}

uses
   System, System.Collections.Generic, System.Linq, System.Text, 
   Tao.OpenGl, Tao.FreeGlut,
   System.Drawing, System.Drawing.Imaging;

//****************************************************// 
//********         Описание вектора         **********//
//****************************************************//   
type
  Vector3D = record
    X, Y, Z:  real;
end;   

//****************************************************// 
//********            Класс камеры          **********//
//****************************************************//  
type
  Camera = class
  private 
    mPos: Vector3D;    // Вектор позиции камеры 
    mView: Vector3D;   // Направление, куда смотрит камера 
    mUp: Vector3D;     // Вектор направления вверх
    mStrafe: Vector3D;  // Вектор для стрейфа (движения влево и вправо) камеры
    
    //--------------------------------------------------------------
    // Перпендикулярный вектор от трех переданных векторов
    //--------------------------------------------------------------
    function Cross(vV1, vV2, vVector2: Vector3D): Vector3D;
    var
      vNormal, vVector1: Vector3D;
    begin
      vVector1.x := vV1.x - vV2.x; 
      vVector1.y := vV1.y - vV2.y; 
      vVector1.z := vV1.z - vV2.z; 
      
      // Если у нас есть 2 вектора (вектор взгляда и вертикальный вектор), 
      // У нас есть плоскость, от которой мы можем вычислить угол в 90 градусов. 
      // Рассчет cross'a прост, но его сложно запомнить с первого раза. 
      // Значение X для вектора = (V1.y * V2.z) - (V1.z * V2.y) 
      vNormal.x := ((vVector1.y * vVector2.z) - (vVector1.z * vVector2.y)); 
      vNormal.y := ((vVector1.z * vVector2.x) - (vVector1.x * vVector2.z)); 
      vNormal.z := ((vVector1.x * vVector2.y) - (vVector1.y * vVector2.x)); 
      
      result :=  vNormal; 
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
    // Установить позицию камеры
    //--------------------------------------------------------------
    procedure Position_Camera(pos_x, pos_y, pos_z, view_x, view_y, view_z, 
                                                   up_x, up_y, up_z : real);
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
    // Перемещение камеры (вперед и назад)
    //--------------------------------------------------------------
    procedure Move_Camera(speed: real); 
    var
      vVector:  Vector3D;
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
      mPos.y +=  speed; 
      mView.y +=  speed;       
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
      vCross : Vector3D;
    begin
      vCross := Cross(mView, mPos, mUp); 
      
      // Нормализуем вектор стрейфа 
      mStrafe := Normalize(vCross); 
    end;
    
 //--------------------------------------------------------------
    // Возвращает позицию камеры по Х
    //--------------------------------------------------------------
    function getPosX: real;
    begin
      Result :=  mPos.x; 
    end;
    
    //--------------------------------------------------------------
    // Возвращает позицию камеры по Y
    //--------------------------------------------------------------
    function getPosY() : real;
    begin
      Result :=  mPos.y; 
    end;
    
    //--------------------------------------------------------------
    // Возвращает позицию камеры по Z
    //--------------------------------------------------------------
    function getPosZ() : real;
    begin
      Result :=  mPos.z; 
    end;
    
 //--------------------------------------------------------------
    // Возвращает позицию взгляда по Х
    //--------------------------------------------------------------    
    function getViewX() : real;
    begin
      Result :=  mView.x; 
    end;
    
    //--------------------------------------------------------------
    // Возвращает позицию взгляда по Y
    //--------------------------------------------------------------
    function getViewY() : real;
    begin
      Result :=  mView.y; 
    end;
    
    //--------------------------------------------------------------
    // Возвращает позицию взгляда по Z
    //--------------------------------------------------------------
    function getViewZ() : real;
    begin
      Result :=  mView.z; 
    end;
    

end; //END CLASS
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

var
  posX : single  := 0.0;
  posY : single  := 0.0;
  posZ : single  := 10.0;
  rotY : single  := 0.0;
  
  Texture : integer;
  Texture2 : integer;
  
   Cam: Camera;
  
//****************************************************// 
//*******      Процедура создания куба      **********//
//****************************************************// 
procedure DrawCube();
begin
  // front
  GL.glColor3f(1.0, 0.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0,  2.0); // 1
    gl.glVertex3f( -2.0, -2.0,  2.0); // 2 
    gl.glVertex3f(  2.0, -2.0,  2.0); // 3
    gl.glVertex3f(  2.0,  2.0,  2.0); // 4
  GL.glEnd();
 
  // back
  GL.glColor3f(0.0, 1.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0, -2.0); // 5
    gl.glVertex3f( -2.0, -2.0, -2.0); // 6
    gl.glVertex3f(  2.0, -2.0, -2.0); // 7
    gl.glVertex3f(  2.0,  2.0, -2.0); // 8
  GL.glEnd();
  
  // left
  GL.glColor3f(0.0, 0.0, 1.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0, -2.0); // 5
    gl.glVertex3f( -2.0, -2.0, -2.0); // 6
    gl.glVertex3f( -2.0, -2.0,  2.0); // 2 
    gl.glVertex3f( -2.0,  2.0,  2.0); // 1
  GL.glEnd();
  
  // right
  GL.glColor3f(1.0, 1.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f(  2.0, -2.0, -2.0); // 7
    gl.glVertex3f(  2.0,  2.0, -2.0); // 8
    gl.glVertex3f(  2.0,  2.0,  2.0); // 4    
    gl.glVertex3f(  2.0, -2.0,  2.0); // 3
  GL.glEnd();
   
  // top
  GL.glColor3f(1.0, 0.0, 1.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0,  2.0); // 1
    gl.glVertex3f(  2.0,  2.0,  2.0); // 4    
    gl.glVertex3f(  2.0,  2.0, -2.0); // 8
    gl.glVertex3f( -2.0,  2.0, -2.0); // 5
  GL.glEnd();

  // down
  GL.glColor3f(0.5, 0.0, 0.5);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f(  2.0, -2.0,  2.0); // 3
    gl.glVertex3f( -2.0, -2.0,  2.0); // 2  
    gl.glVertex3f( -2.0, -2.0, -2.0); // 6
    gl.glVertex3f(  2.0, -2.0, -2.0); // 7
  GL.glEnd();
end;

procedure MYQUAD( Tex : integer);
begin
  Gl.glBindTexture(Gl.GL_TEXTURE_2D, Tex);
  GL.glBegin(GL.GL_QUADS);
  Gl.glTexCoord2f(0, 0);  gl.glVertex3f( -2.0,  2.0,  0.0); // 1
  Gl.glTexCoord2f(0, 1);  gl.glVertex3f( -2.0, -2.0,  0.0); // 2 
  Gl.glTexCoord2f(1, 1);  gl.glVertex3f(  2.0, -2.0,  0.0); // 3
  Gl.glTexCoord2f(1, 0);  gl.glVertex3f(  2.0,  2.0,  0.0); // 4
  GL.glEnd();
end;

procedure MYQUAD2( Tex : integer);
begin
  Gl.glBindTexture(Gl.GL_TEXTURE_2D, Tex);
  GL.glBegin(GL.GL_QUADS);
  Gl.glTexCoord2f(0, 0);  gl.glVertex3f( -2.0,  2.0,  0.0); // 1
  Gl.glTexCoord2f(0, 2.5);  gl.glVertex3f( -2.0, -2.0,  0.0); // 2 
  Gl.glTexCoord2f(2.5, 2.5);  gl.glVertex3f(  2.0, -2.0,  0.0); // 3
  Gl.glTexCoord2f(2.5, 0);  gl.glVertex3f(  2.0,  2.0,  0.0); // 4
  GL.glEnd();
end;


procedure MYTRIANGLE( Tex : integer);
begin
  Gl.glBindTexture(Gl.GL_TEXTURE_2D, Tex);
  GL.glBegin(GL.GL_TRIANGLES);
  Gl.glTexCoord2f(0.5, 1);  gl.glVertex3f(  0.0,  2.0,  0.0); // 1
  Gl.glTexCoord2f(0, 0);  gl.glVertex3f( -2.0, -2.0,  0.0); // 2 
  Gl.glTexCoord2f(1, 0);  gl.glVertex3f(  2.0, -2.0,  0.0); // 3
  GL.glEnd();
end;

//****************************************************// 
//********         Загрузка текстуры        **********//
//****************************************************//
// BMP, GIF, EXIG, JPG, PNG и TIFF
function LoadTextere (filename : string)  : integer;
var 
 texID : integer; 
begin
 var img : Bitmap := new Bitmap (filename);
 var rect : Rectangle := new Rectangle(0, 0, img.Width, img.Height);
 var img_data : BitmapData := img.LockBits (rect,ImageLockMode.ReadOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
 
 Gl.glGenTextures( 1, texID); 
 WriteLn( texID );
  
 Gl.glBindTexture(Gl.GL_TEXTURE_2D, texID);
 
 Gl.glTexParameteri( Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_WRAP_S, Gl.GL_CLAMP);
 Gl.glTexParameteri( Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_WRAP_T, Gl.GL_CLAMP);
 
 var nMaxAnisotropy : integer := 0;
 Gl.glGetIntegerv(Gl.GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT,nMaxAnisotropy); 
 WriteLn('Max ANISOTROPY:', nMaxAnisotropy);
 
 if (nMaxAnisotropy > 0) then
   Gl.glTexParameteri( Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_MAX_ANISOTROPY_EXT, nMaxAnisotropy);
 
 
  Gl.glTexParameteri( Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_MIN_FILTER, Gl.GL_LINEAR_MIPMAP_LINEAR);
  Gl.glTexParameteri( Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_MAG_FILTER, Gl.GL_LINEAR);
 
  Gl.glTexImage2D(Gl.GL_TEXTURE_2D, 0, Gl.GL_RGBA, img_data.Width, img_data.Height, 0, Gl.GL_BGRA,Gl.GL_UNSIGNED_BYTE, img_data.Scan0);
  Gl.glGenerateMipmapEXT(Gl.GL_TEXTURE_2D);
 
  //Glu.gluBuild2DMipmaps (Gl.GL_TEXTURE_2D, Gl.GL_RGBA, img_data.Width, img_data.Height, Gl.GL_BGRA, Gl.GL_UNSIGNED_BYTE, img_data.Scan0);

  img.UnlockBits(img_data);
 
 Result := texID;
end;
 
//****************************************************// 
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************// 
procedure InitScene();
begin  
  Writeln( GL.glGetString(GL.GL_VERSION));
  GL.glClearColor(0.0, 0.0, 0.0, 0.0); 
  
  gl.glEnable(gl.GL_DEPTH_TEST);
  
 // Gl.glEnable( Gl.GL_TEXTURE_2D );
  
  Gl.glEnable( Gl.GL_ALPHA_TEST);
  Gl.glAlphaFunc( Gl.GL_GREATER, 0.0 );
  
  Gl.glEnable ( Gl.GL_BLEND );
  Gl.glBlendFunc( Gl.GL_SRC_ALPHA, Gl.GL_ONE_MINUS_SRC_ALPHA );
  Gl.glBlendEquation( Gl.GL_FUNC_ADD );
  
  
 // Gl.glEnable(Gl.GL_CULL_FACE);
 // Gl.glCullFace(Gl.GL_BACK); 
 // Gl.glFrontFace(Gl.GL_CW);
  
 // Gl.glPolygonMode(Gl.GL_FRONT, Gl.GL_LINE);
 
// img := new Bitmap (Image.FromFile('data\tex2.bmp'));
 
 Texture :=  LoadTextere ('data\a2.png');
 Texture2 :=  LoadTextere ('data\tex1.jpg');
 
 // Создание камеры и задание первоначальных значений
 Cam := new Camera();
 Cam.Position_Camera(0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
 
 
end;

//****************************************************// 
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************// 
procedure RenderScene();
var 
 i , j : integer;
begin
 GL.glLoadIdentity();
 GL.glClear(GL.GL_COLOR_BUFFER_BIT or GL.GL_DEPTH_BUFFER_BIT);
 {
 Glu.gluLookAt( posX, posY, posZ,
                posX, posY, posZ - 3.0,
                0.0, 1.0, 0.0);  
  }
  
  Cam.Look();



 for  i := -10 to 10 do 
  for j := -10 to 10 do begin
   Gl.glPushMatrix(); 
    Gl.glTranslatef( 1.0 * i, -1.5, 1.0 * j );
    Gl.glColor3f( 0.1 * i, 0.3, 0.1 * j );
    Glut.glutSolidCube(0.5);
   Gl.glPopMatrix(); 
  end;
  
  Gl.glPushMatrix(); 
   Gl.glTranslatef( 0.0, -1.5, 0.0 );
   Gl.glColor3f( 0.9, 0.3, 0.7);
   Glut.glutSolidTeapot(1.0);
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

 gl.glViewport(0,0, w, h);
 gl.glMatrixMode(gl.GL_PROJECTION);
 gl.glLoadIdentity();
 
 glu.gluPerspective(45, w/h, 0.1, 10000.0);

 gl.glMatrixMode(gl.GL_MODELVIEW);
 gl.glLoadIdentity();

end;

procedure pressKey ( key : byte; x, y : integer );
begin
 case key of
  Key_W  : Cam.Move_Camera( 1.0);
  Key_S  : Cam.Move_Camera(-1.0);
  Key_A  : Cam.Strafe(-1.0);
  Key_D  : Cam.Strafe( 1.0);
  Key_Q  : Cam.Rotate_View(-0.05); 
  Key_E  : Cam.Rotate_View( 0.05);
  Key_Z  : Cam.upDownAngle (-0.05);
  Key_X  : Cam.upDownAngle ( 0.05);
  
  Key_ESC : glut.glutLeaveMainLoop(); 
  else writeln( key );
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
  
  glut.glutKeyboardFunc ( pressKey );
  
  InitScene();
  Glut.glutMainLoop();
end.
