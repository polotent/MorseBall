unit pop_up_window;

interface

procedure draw_window(str: string);
procedure occasions(occasion: string);
implementation

uses
  graphABC, mouse_on_button;

const
  //colors
  background_color = clLightSteelBlue;
  highlighted_color = clAquamarine;
  deactive_color = clgray;
  color_1 = clblack;
  color_2 = clwhite;
  //cordinates
  center_x = windowwidth div 2;
  center_y = windowheight div 2;
  dx = windowwidth div 32;
  dy = windowheight div 32;
  dr = windowheight div 100 - 2;

var
  //sounds
  sound: system.Media.SoundPlayer;
  //buttins
  size: integer;
  button_color: color;
  //boolean of finishing the procedure occasions
  end_bool: boolean;
  //mouse
  mouse_x, mouse_y: integer;
  moving_mouse_x, moving_mouse_y: integer;
  //what to write in the window
  message: string;
  //valuse of round money
  round_money: integer;
  //string
  global_str: array[1..47] of string;
  //options
  options_str: array [1..6] of string;

{-----------------------------------procedures--------------------------------------}
//filling buttons names ans etc.
procedure fill_str;
var
  filetext, filetext1: text;
  language: string;
  i: integer;
begin
  assign(filetext, 'config\options.txt'); reset(filetext);
  readln(filetext);
  readln(filetext, language);
  if language = 'ENGLISH' then begin
    assign(filetext1, 'config\eng.txt'); reset(filetext1);
    for i := 1 to 47 do 
    begin
      readln(filetext1, global_str[i]);
    end;
    close(filetext1);                  
  end;
  if language = 'RUSSIAN' then begin
    assign(filetext1, 'config\rus.txt'); reset(filetext1);
    for i := 1 to 47 do 
    begin
      readln(filetext1, global_str[i]);
    end;
    close(filetext1);                  
  end;
  close(filetext);
end;
//reading options
procedure get_options;
var
  filetext: text;
begin
  assign(filetext, 'config\options.txt');reset(filetext);
  readln(filetext, options_str[1]);
  readln(filetext, options_str[2]);
  readln(filetext, options_str[3]);
  readln(filetext, options_str[4]);
  readln(filetext, options_str[5]);
  readln(filetext, options_str[6]);
  close(filetext);
end;
//playing sound if the button pressed
procedure button_sound;
begin
  if options_str[1] = 'YES' then begin
    sound := new system.Media.SoundPlayer;
    sound.SoundLocation := 'music\button_sound.wav';
    sound.Play;
  end;
end;


procedure get_round_money;
var
  filetext: text;
begin
  assign(filetext, 'config\round_money.txt');reset(filetext);
  readln(filetext, round_money);
  close(filetext);
end;

procedure onmouse_pop_up;
begin
  //checking for pressing mouse
  onmousedown := position_of_mouse;
    //checking for moving mouse
  onmousemove := position_of_moving_mouse;
    {---------------------------------------------------------------}
    {equalation between unit and program valuse of mouse coordinates}
    {---------------------------------------------------------------}
  mouse_x := show_mouse_x;
  mouse_y := show_mouse_y;
  moving_mouse_x := show_moving_mouse_x;
  moving_mouse_y := show_moving_mouse_y;
end;

procedure check_button_pop_up;
begin
  begin
    if (moving_mouse_x > round(center_x - 4.5 * dx - size - dr)) and (moving_mouse_x < round(center_x + 4.5 * dx + size + dr)) and (moving_mouse_y > round(center_y  - size - dr)) and (moving_mouse_y < round(center_y + 3.5 * dy + size + dr) ) then begin
      if size <> 4 then inc(size, 2);
      button_color := highlighted_color;
    end
    else begin
      if size <> 0 then dec(size, 2);
      button_color := deactive_color;
    end;
    if (mouse_x > round(center_x - 4.5 * dx - size - dr)) and (mouse_x < round(center_x + 4.5 * dx + size + dr)) and (mouse_y > round(center_y  - size - dr)) and (mouse_y < round(center_y + 3.5 * dy + size + dr) ) then begin
      button_sound;
      end_bool := true;
    end;
  end;
end;

procedure button_pop_up;
begin
  rectangle(round(center_x - 4.5 * dx - size - dr), round(center_y  - size - dr), round(center_x + 4.5 * dx + size + dr), round(center_y + 3.5 * dy + size + dr));
  setbrushcolor(button_color);
  fillrectangle(round(center_x - 4.5 * dx - size), round(center_y - size), round(center_x + 4.5 * dx + size), round(center_y + 3.5 * dy + size));
  setbrushcolor(color_2);
  rectangle(round(center_x - 3.5 * dx - size), round(center_y + dy - size), round(center_x + 3.5 * dx + size), round(center_y + 2.5 * dy + size));
  setbrushstyle(bsclear);
  drawtextcentered(round(center_x - 3.5 * dx - size), round(center_y + dy - size), round(center_x + 3.5 * dx + size), round(center_y + 2.5 * dy + size), 'O K');
  setbrushstyle(bssolid);
end;

procedure draw_window(str: string);
begin
  rectangle(round(center_x - 4.5 * dx - dr * 3), round(center_y - 3.5 * dy - dr * 3), round(center_x + 4.5 * dx + dr * 3), round(center_y + 3.5 * dy + dr * 3));
  rectangle(round(center_x - 4.5 * dx - dr * 2), round(center_y - 3.5 * dy - dr * 2), round(center_x + 4.5 * dx + dr * 2), round(center_y + 3.5 * dy + dr * 2));
  button_pop_up;
  setbrushstyle(bsclear);
  drawtextcentered(round(center_x - 4.5 * dx - dr * 2), round(center_y - 3.5 * dy - dr * 2), round(center_x + 4.5 * dx + dr * 2), center_y, str);
  setbrushstyle(bssolid);
end;

procedure occasions(occasion: string);
begin
  fill_str;
  get_options;
  get_round_money;
  message := '';
  button_color := deactive_color;
  size := 0;
  case occasion of
    'try_story', 'try_theme': message := global_str[29];
    'buy_story', 'buy_theme': message := global_str[30];
    'restore_purchases': message := global_str[31];
    'restore_stats': message := global_str[40];
    'phrase_complete': message := global_str[32] + ' = ' + inttostr(round_money);
    'start': message := global_str[33];
    'stop': message := global_str[34] + ' = ' + inttostr(round_money);
    'closed': message := global_str[35];
  end;
  lockdrawing;
  repeat
    onmouse_pop_up;
    draw_window(message);
    button_pop_up;
    check_button_pop_up;
    clear_mouse_xy;
    redraw;
  until end_bool = true;
  end_bool := false;
  message := '';
end;

begin
  clearwindow(background_color);
  setfontsize((windowwidth div 100) + 6);
end.