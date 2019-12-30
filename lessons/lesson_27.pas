{$reference Tao.FreeGlut.dll}
{$reference Tao.OpenGl.dll}
{$reference System.Drawing.dll}

uses
   System, System.Collections.Generic, System.Linq, System.Text,
   System.Drawing, System.Drawing.Imaging,
   Tao.OpenGl, Tao.FreeGlut;

// Платформа
type
  TPlatform = record
    posX : real;
    posY : real;
end;  



const
  Key_W = 119; 
  Key_S = 115;
  Key_A = 97;
  Key_D = 100;
  Key_ESC = 27;
 
const
  AppWidth = 400;
  AppHeight = 533;
  CountPlatfrm = 15;
  
  
var 
  t1, t2, t3 : integer;
  ArrPlatfrm : array[1..CountPlatfrm] of TPlatform; 
  PosX, PosY : real;
  Dy : real;
 
  
  


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
//***                Создание спрайта             ***//
//****************************************************// 
procedure DrawQuad(w, h, tex : integer);
begin
  Gl.glBindTexture(Gl.GL_TEXTURE_2D, tex);
  GL.glBegin(Gl.GL_QUADS);
   Gl.glTexCoord2f(0, 1);  GL.glVertex2f(0, 0);
   Gl.glTexCoord2f(1, 1); GL.glVertex2f(w, 0);
   Gl.glTexCoord2f(1, 0);  GL.glVertex2f(w, h);
   Gl.glTexCoord2f(0, 0);  GL.glVertex2f(0, h);
  GL.glEnd();
end;


//***********************************//
//**    Старт/перезапуск игры      **//
//***********************************//
procedure StartGames();
var 
 i : integer;
 rnd : Random;
begin
 PosX := 100;
 PosY := 50;
 Dy := 0;
 
 rnd := new Random;
 for i:= 1 to CountPlatfrm do begin
  ArrPlatfrm[i].posX := rnd.Next(0, AppWidth);
  ArrPlatfrm[i].posY := rnd.Next(0, AppHeight);
 end;
 
 ArrPlatfrm[1].posX := 100;
 ArrPlatfrm[1].posY := 0;
 
  
end; 



//****************************************************// 
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************// 
procedure InitScene();
begin  
  Writeln( GL.glGetString(GL.GL_VERSION));
  GL.glClearColor(0.3, 0.7, 0.9, 1.0); 
  GL.glEnable(gl.GL_DEPTH_TEST);
  
  // Работа с текстурами
  Gl.glEnable( Gl.GL_TEXTURE_2D );
  Gl.glEnable(Gl.GL_ALPHA_TEST);
  Gl.glAlphaFunc(Gl.GL_GREATER, 0.0);
  Gl.glEnable(Gl.GL_BLEND);
  Gl.glBlendFunc(Gl.GL_SRC_ALPHA, Gl.GL_ONE_MINUS_SRC_ALPHA);
  Gl.glBlendEquation(Gl.GL_FUNC_ADD);
  
  
  
  t1 := LoadTextere('images/background.png');
  t2 := LoadTextere('images/platform.png');
  t3 := LoadTextere('images/doodle3.png');
  
  StartGames();
end;



//****************************************************// 
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************// 
procedure RenderScene();
var
 i : integer;
 rnd : Random;
begin
 GL.glLoadIdentity();
 GL.glClear(GL.GL_COLOR_BUFFER_BIT or GL.GL_DEPTH_BUFFER_BIT);
 
  // Фон 
  Gl.glPushMatrix;
   Gl.glTranslatef(0.0, 0.0, 0.0);
   DrawQuad (AppWidth, AppHeight, t1 );
  Gl.glPopMatrix;
  
   
  
  // Платформы
  for i := 1 to CountPlatfrm do begin
    Gl.glPushMatrix;
      Gl.glTranslatef(ArrPlatfrm[i].posX, ArrPlatfrm[i].posY, 0.1);
      DrawQuad (68, 14, t2 );
    Gl.glPopMatrix;
  end;
  
  
  Dy   := Dy - 0.1;
  PosY := PosY + Dy;
  if (PosY < 0) then Dy := 5;
  
  
  for i := 1 to CountPlatfrm do begin
    if ((PosX + 45 > ArrPlatfrm[i].posX) and (PosX + 25 < ArrPlatfrm[i].posX + 68) and
        (PosY > ArrPlatfrm[i].posY) and (PosY < ArrPlatfrm[i].posY + 14) and
   (Dy < 0)) then begin Dy := 6;  break; end;
  end;
  
  
  rnd :=  new Random;
  if (PosY > 300) then 
    for i:= 1 to CountPlatfrm do begin
      PosY := 300;
      ArrPlatfrm[i].posY := ArrPlatfrm[i].posY - Dy;
      if (ArrPlatfrm[i].posY < 0) then begin
        ArrPlatfrm[i].posY := 533;
        ArrPlatfrm[i].posX := rnd.Next(0, AppWidth);
      end;
    end;
  
  
  
  if (PosY < 10) then StartGames; 
  
  // Персонаж
  Gl.glPushMatrix;
   Gl.glTranslatef(PosX, PosY, 0.2);
   DrawQuad (50, 50, t3 );
  Gl.glPopMatrix;

   
  Glut.glutSwapBuffers;
 // Glut.glutPostRedisplay();
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
 GLU.gluOrtho2D(0, w, 0, h);
 gl.glMatrixMode(gl.GL_MODELVIEW);
 gl.glLoadIdentity();

end;

//****************************************************// 
//****   Процедура обработки нажатия клавишь      ****//
//****************************************************// 
procedure pressKey ( key : byte; x, y : integer );
begin
 case key of
//  Key_W  : 
//  Key_S  : 
  Key_A  : PosX := PosX - 5.0;
  Key_D  : PosX := PosX + 5.0; 
  Key_ESC : glut.glutLeaveMainLoop(); 
 // else writeln( key );
 end;

end;


//------------------------------------------------//
//-  Функция таймер, обработка событий на сцене  -//
//------------------------------------------------//
procedure Update(value : integer);
begin
 
  Glut.glutPostRedisplay();
  Glut.glutTimerFunc(10, Update, 0);
end;


//****************************************************// 
//********             MAIN PROGRAM            *******//
//****************************************************// 
begin
  Glut.glutInit(); 
  Glut.glutInitWindowSize(AppWidth, AppHeight);
  
  Glut.glutInitWindowPosition((Glut.glutGet(glut.GLUT_SCREEN_WIDTH) - AppWidth) div 2,
                              (Glut.glutGet(glut.GLUT_SCREEN_HEIGHT) - AppHeight) div 2);
                              
  Glut.glutInitDisplayMode(GLUT.GLUT_RGBA or Glut.GLUT_DOUBLE or GLUT.GLUT_DEPTH);
  Glut.glutCreateWindow('DoodleJump Game');  
  Glut.glutDisplayFunc(RenderScene);
  Glut.glutReshapeFunc(Reshape);
  
  Glut.glutTimerFunc(10, Update, 0);
 
  
  
  glut.glutKeyboardFunc ( pressKey );
  
  InitScene();
  Glut.glutMainLoop();
end.
