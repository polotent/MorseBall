unit mouse_on_button;

interface

procedure position_of_mouse(x, y, mb: integer);
procedure position_of_moving_mouse(x, y, mb: integer);
procedure clear_mouse_xy;

function show_mouse_x: integer;
function show_mouse_y: integer;

function show_moving_mouse_x: integer;
function show_moving_mouse_y: integer;
implementation

var
  mouse_x, mouse_y: integer;
  moving_mouse_x, moving_mouse_y: integer;
//checking position of pressed mouse
procedure position_of_mouse(x, y, mb: integer);
begin
  mouse_x := x;
  mouse_y := y;
end;
//checking posotion of ALWAYS moving mouse
procedure position_of_moving_mouse(x, y, mb: integer);
begin
  moving_mouse_x := x;
  moving_mouse_y := y;
end;
//clearing x,y coordinates of mouse
procedure clear_mouse_xy;
begin
  mouse_x := 0;
  mouse_y := 0;
end;
//connection between unit mouse_x and program mouse_x
function show_mouse_x; 
begin
  result := mouse_x;
end;
//connection between unit mouse_y and program mouse_y
function show_mouse_y; 
begin
  result := mouse_y;
end;
//connection between unit moving_mouse_x and program moving_mouse_x
function show_moving_mouse_x; 
begin
  result := moving_mouse_x;
end;
//connection between unit moving_mouse_y and program moving_mouse_y
function show_moving_mouse_y; 
begin
  result := moving_mouse_y;
end;
end.