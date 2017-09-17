{$reference Tao.FreeGlut.dll}
{$reference Tao.OpenGl.dll}
   
uses
   System, System.Collections.Generic, System.Linq, System.Text, 
   Tao.OpenGl, Tao.FreeGlut;

// Инициализация ресурсов приложения и OpenGL
 procedure InitScene;
 begin
  Writeln( GL.glGetString(GL.GL_VERSION));
 end;

// Процедура отрисовки
// Данная процедура вызывается каждый кадр
 procedure RenderScene();
 begin
 end;

// Процедура перенастройки
// Данная процедура вызывается при изменении размера экрана
 procedure Reshape( w, h:integer);
 begin
 end;

 
 begin
  Glut.glutInit(); 
  Glut.glutInitWindowSize(400, 300);
  Glut.glutInitWindowPosition(300, 200); 
  Glut.glutInitDisplayMode(GLUT.GLUT_RGBA);
  Glut.glutCreateWindow('Tao Example');  
  Glut.glutDisplayFunc(RenderScene);
  Glut.glutReshapeFunc(Reshape);
  
  InitScene();
  Glut.glutMainLoop();
 end.
