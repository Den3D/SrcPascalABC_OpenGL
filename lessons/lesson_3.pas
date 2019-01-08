{$reference Tao.FreeGlut.dll}
{$reference Tao.OpenGl.dll}
   
uses
   System, System.Collections.Generic, System.Linq, System.Text, 
   Tao.OpenGl, Tao.FreeGlut;

var
  r : single;
 
// Инициализация ресурсов приложения и OpenGL
 procedure InitScene();
 begin
  Writeln( GL.glGetString(GL.GL_VERSION));
  GL.glClearColor(0.0, 0.0, 0.0, 0.0); 
 end;

// Процедура отрисовки
// Данная процедура вызывается каждый кадр
 procedure RenderScene();
 begin
  GL.glClear(GL.GL_COLOR_BUFFER_BIT);
  GL.glPointSize(3.0);
  GL.glLineWidth(3.0);
  
  GL.glBegin(GL.GL_LINE_LOOP);
    GL.glColor3f(1.0,0.0,0.0);
    GL.glVertex2f(-0.5, 0.5);    
    GL.glColor3f(0.0,1.0,0.0);
    GL.glVertex2f( 0.5, 0.5);
    GL.glColor3f(0.0,0.0,1.0);
    GL.glVertex2f( 0.5,-0.5);
    GL.glColor3f(0.5,0.5,0.5);
    GL.glVertex2f(-0.5,-0.5);    
  GL.glEnd();
  
  GL.glFinish();
 // Glut.glutPostRedisplay();
 end;
 
 procedure Timer (val : integer);
 begin
  Glut.glutPostRedisplay();
  Glut.glutTimerFunc(40, Timer, 0);
 end;

// Процедура перенастройки
// Данная процедура вызывается при изменении размера экрана
 procedure Reshape( w, h : integer);
 begin
 end;

 //---------------------------------------------------------------------
 begin
  Glut.glutInit(); 
  Glut.glutInitWindowSize(400, 300);
  Glut.glutInitWindowPosition(300, 200); 
  Glut.glutInitDisplayMode(GLUT.GLUT_RGBA);
  Glut.glutCreateWindow('Tao Example');  
  Glut.glutDisplayFunc(RenderScene);
  Glut.glutReshapeFunc(Reshape);
  Glut.glutTimerFunc(40, Timer, 0);
  InitScene();
  Glut.glutMainLoop();
 end.
