 {$reference Tao.FreeGlut.dll}
 {$reference Tao.OpenGl.dll}
   
 uses
   System, System.Collections.Generic, System.Linq, System.Text, 
   Tao.OpenGl, Tao.FreeGlut;

 procedure init_graphics;
 begin

 end;

 procedure on_display();
 begin

 end;

 procedure on_reshape( w, h:integer);
 begin

 end;

 begin
   Glut.glutInit();
   Glut.glutInitWindowSize(500, 500);
   Glut.glutCreateWindow('Tao Example');
   init_graphics();
   Glut.glutDisplayFunc(on_display);
   Glut.glutReshapeFunc(on_reshape);
   Glut.glutMainLoop();
 end.
