{$reference Tao.FreeGlut.dll}
{$reference Tao.OpenGl.dll}

uses
   System, System.Collections.Generic, System.Linq, System.Text, 
   Tao.OpenGl, Tao.FreeGlut;

const
  Width = 600;
  Height = 480;

var
  r : single := 0.0;
  r1 : single := 0.0;
  b : boolean := false;
  
//****************************************************// 
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************// 
procedure InitScene();
begin  
  Writeln( GL.glGetString(GL.GL_VERSION));
  GL.glClearColor(0.0, 0.0, 0.0, 0.0); 
  
  gl.glEnable(gl.GL_DEPTH_TEST);
 // gl.glDepthFunc(gl.GL_LEQUAL);
 // gl.glDepthRange(0.0, 1.0);
 // gl.glDepthMask(gl.GL_TRUE);
 // gl.glClearDepth(1.0); 
end;

//****************************************************// 
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************// 
procedure RenderScene();
begin
 GL.glLoadIdentity();
 Glu.gluLookAt( 0.0, 0.0, 10.0,
                0.0, 1.0, 0.0,
                0.0, 1.0, 0.0);

  GL.glClear(GL.GL_COLOR_BUFFER_BIT or GL.GL_DEPTH_BUFFER_BIT);

  GL.glTranslatef(0.0, 0.0, 0.0);
  GL.glRotatef(r, 0.0, 0.0, 1.0);  

  GL.glScalef(r1, 1.0, 0.0);

  GL.glBegin(GL.GL_TRIANGLES);
     gl.glVertex3f( 0.0, 1.5,  0.0);
     gl.glVertex3f( 0.0, 0.0,  0.0);
     gl.glVertex3f( 1.0, 0.0,  0.0); 
  GL.glEnd();
 
 
  if ((r1 > 2) and(b = false)) then b := true;
  if ((r1 < 0)and(b = true))  then b := false;
  
  if (b = false) then r1 := r1 + 0.1;
  if (b = true)  then r1 := r1 - 0.1;
  
  
  r := r + 1.0;
  
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


begin
  Glut.glutInit(); 
  Glut.glutInitWindowSize(Width, Height);
  Glut.glutInitWindowPosition(300, 200); 
  Glut.glutInitDisplayMode(GLUT.GLUT_RGBA or Glut.GLUT_DOUBLE or GLUT.GLUT_DEPTH);
  Glut.glutCreateWindow('Tao Example');  
  Glut.glutDisplayFunc(RenderScene);
  Glut.glutReshapeFunc(Reshape);
  Glut.glutTimerFunc(40, Timer, 0);
  InitScene();
  Glut.glutMainLoop();
end.
