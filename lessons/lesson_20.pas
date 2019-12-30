{$reference Tao.FreeGlut.dll}
{$reference Tao.OpenGl.dll}
{$reference System.Drawing.dll}

uses
   System, System.Collections.Generic, System.Linq, System.Text, 
   Tao.OpenGl, Tao.FreeGlut,
   System.Drawing, System.Drawing.Imaging;

const
  Key_W = 119; 
  Key_S = 115;
  Key_A = 97;
  Key_D = 100;
  Key_ESC = 27;

const
  Width = 600;
  Height = 480;

var
  posX : single  := 0.0;
  posY : single  := 0.0;
  posZ : single  := -5.0;
  
  Texture : integer;
  Texture2 : integer;
  
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

procedure AAA( Tex : integer);
begin

  Gl.glBindTexture(Gl.GL_TEXTURE_2D, Tex);
  GL.glBegin(GL.GL_QUADS);
  Gl.glTexCoord2f(0, 1);  gl.glVertex3f( -2.0,  2.0,  2.0); // 1
  Gl.glTexCoord2f(0, 0);  gl.glVertex3f( -2.0, -2.0,  2.0); // 2 
  Gl.glTexCoord2f(1, 0);  gl.glVertex3f(  2.0, -2.0,  2.0); // 3
  Gl.glTexCoord2f(1, 1);  gl.glVertex3f(  2.0,  2.0,  2.0); // 4
  GL.glEnd();
end;


procedure AAA2( Tex : integer);
begin

  Gl.glBindTexture(Gl.GL_TEXTURE_2D, Tex);
  GL.glBegin(GL.GL_QUADS);
  Gl.glTexCoord2f(0, 1);  gl.glVertex3f( -2.0,  2.0,  4.0); // 1
  Gl.glTexCoord2f(0, 0);  gl.glVertex3f( -2.0, -2.0,  4.0); // 2 
  Gl.glTexCoord2f(1, 0);  gl.glVertex3f(  2.0, -2.0,  4.0); // 3
  Gl.glTexCoord2f(1, 1);  gl.glVertex3f(  2.0,  2.0,  4.0); // 4
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
 Glu.gluBuild2DMipmaps (Gl.GL_TEXTURE_2D, Gl.GL_RGBA, img_data.Width, img_data.Height, Gl.GL_BGRA, Gl.GL_UNSIGNED_BYTE, img_data.Scan0);

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
  
  Gl.glEnable( Gl.GL_TEXTURE_2D );
  
  
 // Gl.glEnable(Gl.GL_CULL_FACE);
 // Gl.glCullFace(Gl.GL_BACK); 
 // Gl.glFrontFace(Gl.GL_CW);
  
 // Gl.glPolygonMode(Gl.GL_FRONT, Gl.GL_LINE);
 
// img := new Bitmap (Image.FromFile('data\tex2.bmp'));
 
 Texture :=  LoadTextere ('data\tex2.bmp');
 Texture2 :=  LoadTextere ('data\tex1.jpg');
 
end;

//****************************************************// 
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************// 
procedure RenderScene();
begin
 GL.glLoadIdentity();
 Glu.gluLookAt( posX, 0.0, posZ,
                0.0, 0.0, 0.0,
                0.0, 1.0, 0.0);  

  GL.glClear(GL.GL_COLOR_BUFFER_BIT or GL.GL_DEPTH_BUFFER_BIT);

 
  AAA(Texture);
  
  AAA2(Texture2);

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
  Key_W  : posZ := posZ + 1.0;   
  Key_S  : posZ := posZ - 1.0;  
  Key_A  : posX := posX - 1.0;   
  Key_D  : posX := posX + 1.0;  
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
