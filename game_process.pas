unit game_process;

interface

procedure main_play;
implementation

uses
  graphABC, mouse_on_button, pop_up_window, timers;

const
  //colors
  background_color = clLightSteelBlue;
  active_color = RGB(217,226,157);
  highlighted_color = clAquamarine;
  deactive_color = clgray;
  letter_deactive_color = RGB(242,226,217);
  location_window_color = RGB(126,189,215);
  highlighted_letter_color = clyellow;
  right_letter_color = cllightgreen;
  wrong_letter_color = cltomato;
  color_1 = clblack;
  color_2 = clwhite;
  //coordinates
  center_x = windowwidth div 2;
  center_y = windowheight div 2;
  dx = windowwidth div 32;
  dy = windowheight div 32;
  dr = windowheight div 100 - 2;

var
  //public process
  public_process: string;
  //reading table or not
  good_reading : string;
  play_mode: string;
  //sounds
  music: system.Media.SoundPlayer;
  sound: array [1..4] of system.Media.SoundPlayer;
  //to check if the game started
  game_start: boolean;
  //mouse x,y
  mouse_x, mouse_y: integer;
  moving_mouse_x, moving_mouse_y: integer;
  //array for pictures used
  pic: array[1..10] of picture;
  //buttons values
  button_x, button_y: array[1..2] of integer;
  button_color: array[1..3] of color;//colors for buttons 
  size: array[1..3] of integer;
  button_name: string;
  //mode buttons values
  mode_button_x, mode_button_y: array[1..2] of integer; 
  mode_button_color: array[1..2] of color;
  mode_size: array[1..2] of integer;
  //morse button
  morse_button_x, morse_button_y: array[1..1] of integer; 
  morse_button_color: array[1..1] of color;
  morse_size: array[1..1] of integer;
  //power panel
  power_level_str: string;
  power_level_x, power_level_y: string;
  power_point_x, power_point_y: integer;
  power_point_str: string;
  //aplhabets for both languages
  alphabet_eng: array[1..26] of char;
  alphabet_morse_eng: array[1..26] of string;
  alphabet_rus: array[1..32] of char;
  alphabet_morse_rus: array[1..32] of string;
  //letter panel
  letters: array[1..10] of char;
  letters_color: array[1..10] of color;
  phrase_complete: boolean;
  letter_int: integer;
  letter_active: integer;
  letter_complete: boolean;  
  rng: integer;
  rng_numb: integer;
  //ball
  throw_ball_bool: boolean;
  ball_speed_x, ball_speed_y: real;
  ball_x, ball_y: integer;
  //wind
  wind_speed: integer;
  wind_change: integer;
  //goals
  field_out: boolean;
  gate_goal: boolean;
  gate_success_num: integer;  
  goal_x, goal_y: array[1..4] of integer;
  goal_str: array[1..4] of string;
  //timer
  t: timer;
  time: integer;
  //money
  amount_of_money, round_money: integer;
  //theme
  theme_using: string;
  //language of the interface and morse code
  global_str: array[1..47] of string;
  language: string;
  //options
  options_str: array [1..6] of string;
  //trajectory
  traj_x, traj_y: array[1..1000] of integer; 
  wind_trajectary: integer;
  build_complete:boolean;
  //stats
  stats_str: array[1..4] of integer;
  //morse picture
  morse_pic : picture;
  //array of indicator pictures
  indicate_pic : array[1..4] of picture;
{---------------------------procedures-------------------------------}
//filling button with names of current language 
procedure fill_str;
var
  filetext, filetext1, filetext2, filetext3: text;
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
    assign(filetext2, 'config\alphabet_morse_eng.txt'); reset(filetext2);
    assign(filetext3, 'config\alphabet_eng.txt'); reset(filetext3);
    for i := 1 to 26 do 
    begin
      readln(filetext2, alphabet_morse_eng[i]);
      readln(filetext3, alphabet_eng[i]);
    end;
    close(filetext2);
    close(filetext3);
  end;
  if language = 'RUSSIAN' then begin
    assign(filetext1, 'config\rus.txt'); reset(filetext1);
    for i := 1 to 47 do 
    begin
      readln(filetext1, global_str[i]);
    end;
    close(filetext1);   
    assign(filetext2, 'config\alphabet_morse_rus.txt'); reset(filetext2);
    assign(filetext3, 'config\alphabet_rus.txt'); reset(filetext3);
    for i := 1 to 32 do 
    begin
      readln(filetext2, alphabet_morse_rus[i]);
      readln(filetext3, alphabet_rus[i]);
    end;
    close(filetext2);
    close(filetext3);
  end;
  close(filetext);
end;
//getting stats from the file
procedure get_stats;
var
  filetext: text;
  i: integer;
begin
  assign(filetext, 'config\stats.txt'); reset(filetext);
  for i := 1 to 4 do readln(filetext, stats_str[i]);
  close(filetext);
end;
//rewriting stats on the file
procedure rewrite_stats;
var
  filetext: text;
  i: integer;
begin
  assign(filetext, 'config\stats.txt'); rewrite(filetext);
  for i := 1 to 4 do writeln(filetext, stats_str[i]);
  close(filetext);
end;

//getting options out of the file
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
    sound[1] := new system.Media.SoundPlayer;
    sound[1].SoundLocation := 'music\button_sound.wav';
    sound[1].Play;
  end;
end;
//playing sound of happy crowd
procedure happy_sound;
begin
  if options_str[1] = 'YES' then begin
    sound[2] := new system.Media.SoundPlayer;
    sound[2].SoundLocation := 'music\happy_sound.wav';
    sound[2].Play;
  end;
end;
//playing sound of unhappy crowd
procedure unhappy_sound;
begin
  if options_str[1] = 'YES' then begin
    sound[3] := new system.Media.SoundPlayer;
    sound[3].SoundLocation := 'music\unhappy_sound.wav';
    sound[3].Play;
  end;
end;
//playing sound of ball
procedure ball_sound;
begin
  if options_str[1] = 'YES' then begin
    sound[4] := new system.Media.SoundPlayer;
    sound[4].SoundLocation := 'music\ball_sound.wav';
    sound[4].Play;
  end;
end;
//getting mouse position from unit mouse_on_button
procedure onmouse;
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
//getting the theme to use
procedure get_theme_using;
var
  filetext: text;
begin
  assign(filetext, 'config\theme_using.txt');reset(filetext);
  readln(filetext, theme_using);
  close(filetext);
end;
//initialization
procedure initialize_gameprocess;
begin
  get_theme_using;
  //buttons
  button_x[1] := center_x;
  button_x[2] := center_x + 10 * dx;
  button_y[1] := round(center_y + 12.5 * dy);
  button_y[2] := round(center_y + 12.5 * dy);
  morse_button_x[1] := round(center_x - 10*dx);
  morse_button_y[1] := round(center_y - 15 * dy);
  //pictures
  pic[1] := picture.create('pictures\HUD\power_panel.png');
  pic[2] := picture.create('pictures\HUD\letter_panel.png');
  pic[3] := picture.Create('pictures\HUD\left_arrow.png');
  pic[4] := picture.Create('pictures\HUD\right_arrow.png');
  if theme_using = 'default' then begin
    pic[5] := picture.Create('pictures\themes\default\default_background.png');
    pic[6] := picture.Create('pictures\themes\default\default_goal.png');
    pic[7] := picture.Create('pictures\themes\default\default_ball.png');
  end;
  if theme_using = 'theme1' then begin
    pic[5] := picture.Create('pictures\themes\theme1\football_background.png');
    pic[6] := picture.Create('pictures\themes\theme1\football_goal.png');
    pic[7] := picture.Create('pictures\themes\theme1\football_ball.png');
  end;
  if theme_using = 'theme2' then begin
    pic[5] := picture.Create('pictures\themes\theme2\hockey_background.png');
    pic[6] := picture.Create('pictures\themes\theme2\hockey_goal.png');
    pic[7] := picture.Create('pictures\themes\theme2\hockey_ball.png');
  end;
  if theme_using = 'theme3' then begin
    pic[5] := picture.Create('pictures\themes\theme3\water_polo_background.png');
    pic[6] := picture.Create('pictures\themes\theme3\water_polo_goal.png');
    pic[7] := picture.Create('pictures\themes\theme3\water_polo_ball.png');
  end;
  if options_str[2]='ENGLISH' then morse_pic:=picture.Create('pictures\eng\table\table.png');
  if options_str[2]='RUSSIAN' then morse_pic:=picture.Create('pictures\rus\table\table.png');
  
  indicate_pic[1]:=picture.Create('pictures\HUD\timer_on.png');
  indicate_pic[2]:=picture.Create('pictures\HUD\timer_off.png');
  indicate_pic[3]:=picture.Create('pictures\HUD\table_on.png');
  indicate_pic[4]:=picture.Create('pictures\HUD\table_off.png');
end;
//getting money value out of the file
procedure get_money;
var
  filetext: text;
begin
  assign(filetext, 'config\amount_of_money.txt');reset(filetext);
  readln(filetext, amount_of_money);
  close(filetext);
end;
//rewriting money value in the file
procedure rewrite_money;
var
  filetext: text;
begin
  assign(filetext, 'config\amount_of_money.txt');rewrite(filetext);
  writeln(filetext, amount_of_money);
  close(filetext);
end;
//rewriting earend money into the file for using this value in pop-up window
procedure rewrite_round_money;
var
  filetext: text;
begin
  assign(filetext, 'config\round_money.txt');rewrite(filetext);
  writeln(filetext, round_money);
  close(filetext);
end;
{------------------------------------------timer--------------------------------------------}
procedure dectimer;
begin
  dec(time, 1);
end;
//taking out of motse file combinations, that are the same as letters
function make_rng(chr: char): string;
var
  filetext1, filetext2: text;
  i, j: integer;
  str: string;
  res: string;
begin
  //checking if language is english
  if language = 'ENGLISH' then begin
    assign(filetext1, 'config\alphabet_eng.txt'); reset(filetext1);
    assign(filetext2, 'config\alphabet_morse_eng.txt'); reset(filetext2);
    i := 1;
    repeat
      readln(filetext1, str);
      inc(i);
    until str = chr;
    for j := 1 to i - 2 do readln(filetext2);
    readln(filetext2, res);
    result := res;
  end;
  //checking if language is russian
  if language = 'RUSSIAN' then begin
    assign(filetext1, 'config\alphabet_rus.txt'); reset(filetext1);
    assign(filetext2, 'config\alphabet_morse_rus.txt'); reset(filetext2);
    i := 1;
    repeat
      readln(filetext1, str);
      inc(i);
    until str = chr;
    for j := 1 to i - 2 do readln(filetext2);
    readln(filetext2, res);
    result := res;
  end;
  close(filetext2);
  close(filetext1);
end;
//randomizing morse codes for goals
procedure random_goal_str;
var
  i: integer;
begin
  rng := random(1, 4);
  goal_str[rng] := make_rng(letters[letter_active]);
  repeat
    for i := 1 to 4 do 
    begin
      if language = 'ENGLISH' then begin
        if i <> rng then begin
          rng_numb := random(1, 26);
          goal_str[i] := alphabet_morse_eng[rng_numb]; 
        end;
      end;
      if language = 'RUSSIAN' then begin
        if i <> rng then begin
          rng_numb := random(1, 32);
          goal_str[i] := alphabet_morse_rus[rng_numb]; 
        end;
      end;
    end;
  until (goal_str[1] <> goal_str[2]) and (goal_str[1] <> goal_str[3]) and (goal_str[1] <> goal_str[4]) and (goal_str[2] <> goal_str[3]) and (goal_str[2] <> goal_str[4]) and (goal_str[3] <> goal_str[4]); 
end;
//randomizing positions for goals 
procedure random_objects;
begin
  ball_x := center_x;
  ball_y := round(center_y + 4.5 * dy);
  goal_x[1] := random(round(center_x - 14 * dx + 2 * dx + dr), round(center_x - 14 * dx + 5 * dx + dr));
  goal_x[2] := random(round(center_x - 14 * dx + 9 * dx + dr), round(center_x - 14 * dx + 12 * dx + dr));
  goal_x[3] := random(round(center_x + 14 * dx - 12 * dx - dr), round(center_x + 14 * dx - 9 * dx - dr));
  goal_x[4] := random(round(center_x + 14 * dx - 5 * dx - dr), round(center_x + 14 * dx - 2 * dx - dr));
  repeat
    goal_y[1] := random(round(center_y - 11.5 * dy + dr), round(center_y + 1.5 * dy - dr));
    goal_y[2] := random(round(center_y - 11.5 * dy + dr), round(center_y + 1 * dy - dr));  
  until (goal_y[1] > goal_y[2]);
  repeat
    goal_y[3] := random(round(center_y - 11.5 * dy + dr), round(center_y + 1 * dy - dr));
    goal_y[4] := random(round(center_y - 11.5 * dy + dr), round(center_y + 1.5 * dy - dr));
  until (goal_y[4] > goal_y[3]);  
  random_goal_str;
end;
//checking if the ball is 
procedure check_ball_collision;
begin
  if (goal_x[1] - 3 * dy < ball_x - dy) and (goal_x[1] + 3 * dy > ball_x + dy) and (goal_y[1] - round(1.5 * dy) < ball_y - dy) and (goal_y[1] + round(1.5 * dy) > ball_y + dy) then begin
    gate_goal := true;
    gate_success_num := 1;
  end;
  if (goal_x[2] - 3 * dy < ball_x - dy) and (goal_x[2] + 3 * dy > ball_x + dy) and (goal_y[2] - round(1.5 * dy) < ball_y - dy) and (goal_y[2] + round(1.5 * dy) > ball_y + dy) then begin
    gate_goal := true;
    gate_success_num := 2;
  end;
  if (goal_x[3] - 3 * dy < ball_x - dy) and (goal_x[3] + 3 * dy > ball_x + dy) and (goal_y[3] - round(1.5 * dy) < ball_y - dy) and (goal_y[3] + round(1.5 * dy) > ball_y + dy) then begin
    gate_goal := true;
    gate_success_num := 3;
  end;
  if (goal_x[4] - 3 * dy < ball_x - dy) and (goal_x[4] + 3 * dy > ball_x + dy) and (goal_y[4] - round(1.5 * dy) < ball_y - dy) and (goal_y[4] + round(1.5 * dy) > ball_y + dy) then begin
    gate_goal := true;
    gate_success_num := 4;
  end;
  if (ball_x + dy > center_x + 14 * dx - dr) or (ball_x - dy < center_x - 14 * dx + dr) or (ball_y - dy < center_y - 13 * dy + dr) then field_out := true;
end;
//drawing win and timer
procedure wind_timer_money_panel;
begin
  rectangle(center_x - 14 * dx + dr, center_y + 3 * dy, center_x - 6 * dx + dr, center_y + 6 * dy - dr);
  rectangle(center_x + 10 * dx + dr, center_y + 3 * dy, center_x + 14 * dx - dr, center_y + 6 * dy - dr);
  //wind  
  line(center_x - 10 * dx + dr, center_y + 3 * dy, center_x - 10 * dx + dr, center_y + 6 * dy - dr);
  setfontsize((windowwidth div 100) - 1);
  drawtextcentered(center_x - 14 * dx + dr, center_y + 3 * dy, center_x - 10 * dx + dr, center_y + 4 * dy - dr, global_str[11]);
  if wind_speed = 0 then drawtextcentered(center_x - 14 * dx + dr, center_y + 4 * dy, center_x - 10 * dx + dr, center_y + 6 * dy - dr, inttostr(wind_speed))
  else drawtextcentered(center_x - 14 * dx + dr, center_y + 4 * dy, center_x - 10 * dx + dr, center_y + 5 * dy - dr, inttostr(wind_speed));
  if wind_speed > 0 then pic[4].draw(center_x - 14 * dx + dr + 1, center_y + 5 * dy - dr + 1, 4 * dx - 2, dy - 2);
  if wind_speed < 0 then pic[3].draw(center_x - 14 * dx + dr + 1, center_y + 5 * dy - dr + 1, 4 * dx - 2, dy - 2);
  //timer
  drawtextcentered(center_x - 10 * dx + dr, center_y + 3 * dy, center_x - 6 * dx + dr, center_y + 4 * dy - dr, global_str[12]);  
  if play_mode = 'usual' then drawtextcentered(center_x - 10 * dx + dr, center_y + 4 * dy, center_x - 6 * dx + dr, center_y + 6 * dy - dr, inttostr(time)); 
  if play_mode = 'training' then drawtextcentered(center_x - 10 * dx + dr, center_y + 4 * dy, center_x - 6 * dx + dr, center_y + 6 * dy - dr, '~'); 
  //money
  drawtextcentered(center_x + 10 * dx + dr, center_y + 3 * dy, center_x + 14 * dx - dr, center_y + 4 * dy - dr, global_str[13]);
  setfontsize((windowwidth div 100) + 6);
  drawtextcentered(center_x + 10 * dx + dr, center_y + 4 * dy, center_x + 14 * dx - dr, center_y + 6 * dy - dr, inttostr(amount_of_money));
end;
//coloring letters
procedure letter_fill;
var
  i: integer;
begin
  for i := 1 to 10 do 
  begin
    setbrushcolor(letters_color[i]);                 
    rectangle(round(center_x - 6.4 * dx + i * 1.9 * dx), round(center_y + 7.5 * dy - 0.5 * dy), round(center_x - 4.5 * dx + i * 1.9 * dx), round(center_y + 8.5 * dy + 1.5 * dy));
    drawtextcentered(round(center_x - 6.4 * dx + i * 1.9 * dx), round(center_y + 7.5 * dy - 0.5 * dy), round(center_x - 4.5 * dx + i * 1.9 * dx), round(center_y + 8.5 * dy + 1.5 * dy), letters[i]);
    setbrushcolor(color_2);
  end;
end;
//drawing letters panel
procedure letter_panel;
var
  i, j: integer;
begin
  if phrase_complete = true then for i := 1 to 10 do 
    begin
      time := 60;
      game_start := true;      
      letters_color[1] := highlighted_letter_color;
      for j := 2 to 10 do letters_color[i] := letter_deactive_color;
      letter_active := 1;
      if language = 'ENGLISH' then begin
        letter_int := random(1, 26);
        letters[i] := alphabet_eng[letter_int];
      end;
      if language = 'RUSSIAN' then begin
        letter_int := random(1, 32);
        letters[i] := alphabet_rus[letter_int];
      end;
      phrase_complete := false;      
    end;
  rectangle(round(center_x - 4.5 * dx) - dr, round(center_y + 7.5 * dy - 0.5 * dy) - dr, round(center_x + 10 * dx + 4.5 * dx) + dr, round(center_y + 8.5 * dy + 1.5 * dy) + dr);                                               
  rectangle(round(center_x - 4.5 * dx), round(center_y + 7.5 * dy - 0.5 * dy), round(center_x + 10 * dx + 4.5 * dx), round(center_y + 8.5 * dy + 1.5 * dy));  
  letter_fill;  
end;
//calculating trajectory
procedure calculate_trajectory;
var
  i: integer;
begin
  if options_str[6] = 'YES' then begin
    wind_trajectary := wind_change;
    for i := 1 to 1000 do 
    begin
      traj_x[i] := 0;
      traj_y[i] := 0;
    end;
    traj_x[1] := ball_x;
    traj_y[1] := ball_y;
    i := 2;
    repeat
      traj_x[i] := round((traj_x[i - 1] + 6 * ball_speed_x + 0.25 * wind_trajectary));
      traj_y[i] := round((traj_y[i - 1] - 6 * ball_speed_y)); 
      if wind_trajectary < 0 then dec(wind_trajectary, 1);
      if wind_trajectary > 0 then inc(wind_trajectary, 1); 
      inc(i);
    until (traj_x[i - 1] + dy > center_x + 14 * dx - dr) or (traj_x[i - 1] - dy < center_x - 14 * dx + dr) or (traj_y[i - 1] - dy < center_y - 13 * dy + dr) or (i = 1000); 
  end;
end;
//drawing trajectory
procedure build_trajectory;
var
  i: integer;
  j: integer;
  circled: boolean;
begin
  if options_str[6] = 'YES' then begin
    circled := false;
    i := 2;
    //setbrushcolor(clPaleVioletRed);
    setpencolor(clbrown);
    setpenwidth(dy div 10);
    repeat
      line(traj_x[i - 1], traj_y[i - 1], traj_x[i], traj_y[i]);
      for j := 1 to 4 do 
      begin
        if (goal_x[j] - 3 * dy < traj_x[i] - dy) and (goal_x[j] + 3 * dy > traj_x[i] + dy) and (goal_y[j] - round(1.5 * dy) < traj_y[i] - dy) and (goal_y[j] + round(1.5 * dy) > traj_y[i] + dy) and (circled = false) then begin
          setbrushstyle(bsclear);
          circle(traj_x[i], traj_y[i], dy);
          circled := true;
          setbrushstyle(bssolid);
          build_complete:=true;
        end;
      end;
      inc(i, 1);
      if traj_x[i+1]=0 then build_complete:=true;
    until build_complete=true;
    setpencolor(color_1);
    setpenwidth(1);
  end;
  build_complete:=false;
end;
//process of throwing a ball
procedure throw_ball;
var
  i: integer;
begin
  inc(stats_str[2]);
  rewrite_stats;
  button_name := global_str[8];
  gate_goal := false;
  field_out := false;
  ball_x := center_x;
  ball_y := round(center_y + 4.5 * dy);
  get_money;
  lockdrawing;    
  rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 6 * dy);
  repeat
    drawrectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 6 * dy - dr);
    pic[5].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - 2 * dr - 2, 19 * dy - 2 * dr - 2);     
    for i := 1 to 4 do 
    begin
      pic[6].Draw(goal_x[i] - round(3 * dy) + 1, goal_y[i] - round(1.5 * dy) + 1, 6 * dy - 2, 3 * dy - 2);
      setfontsize((windowwidth div 100) + 20);
      drawtextcentered(goal_x[i] - round(3 * dy), goal_y[i] - round(1.5 * dy), goal_x[i] + round(3 * dy), goal_y[i] + round(1.5 * dy), goal_str[i]);
      setfontsize((windowwidth div 100) + 6);
    end;
    build_trajectory;
    pic[7].Draw(ball_x - dy + 1, ball_y - dy + 1, 2 * dy - 2, 2 * dy - 2);
    ball_x := round((ball_x + 6 * ball_speed_x + 0.25 * wind_change));    
    ball_y := round((ball_y - 6 * ball_speed_y));   
    check_ball_collision;
    wind_timer_money_panel;
    if wind_change < 0 then dec(wind_change, 1);
    if wind_change > 0 then inc(wind_change, 1);    
    if play_mode = 'usual' then begin
      if time = 0 then begin
        t.stop;
        occasions('stop');     
        round_money := 0;
        rewrite_round_money;
        phrase_complete := true;       
        break;
      end;
    end;
    redraw;
  until (field_out = true) or (gate_goal = true);  
  throw_ball_bool := false;
  if (rng = gate_success_num) and (gate_goal = true) then begin
    happy_sound;
    inc(stats_str[4]);
    rewrite_stats;
    letters_color[letter_active] := right_letter_color;
    inc(amount_of_money, 1);
    inc(round_money, 1);
  end
  else begin
    if phrase_complete = false then begin
      unhappy_sound;
      letters_color[letter_active] := wrong_letter_color;
    end;
  end;
  if gate_goal = true then begin
    inc(stats_str[3]);
    rewrite_stats;
  end;
  gate_goal := false;   
  rewrite_round_money;
  if letter_active = 10 then begin
    t.stop;
    phrase_complete := true;
    letter_fill;
    rewrite_round_money;  
    wind_timer_money_panel;
    occasions('phrase_complete');
    round_money := 0;
    rewrite_round_money;  
    letter_panel;
    random_objects;
  end
  else letter_active := letter_active + 1;
  letters_color[letter_active] := highlighted_letter_color;
  if options_str[5] = 'YES' then wind_speed := random(-3, 3)
  else wind_speed := 0;  
  wind_change := wind_speed;  
  rewrite_money;  
  if play_mode = 'usual' then begin
    if time = 0 then letter_panel;
  end;
  for i := 1 to 1000 do 
  begin
    traj_x[i] := 0;
    traj_y[i] := 0;
  end;
  random_objects;
end;
//power panel drawing
procedure power_panel;
begin
  rectangle(round(center_x - 10 * dx - 4.5 * dx) - dr, round(center_y + 7.5 * dy - 0.5 * dy) - dr, round(center_x - 10 * dx + 4.5 * dx) + dr, round(center_y + 12.5 * dy + 1.5 * dy) + dr);
  rectangle(round(center_x - 10 * dx - 4.5 * dx), round(center_y + 7.5 * dy - 0.5 * dy), round(center_x - 10 * dx + 4.5 * dx), round(center_y + 12.5 * dy + 1.5 * dy));
  setpenwidth(4);
  pic[1].Draw(round(center_x - 10 * dx - 4.5 * dx) + 1, round(center_y + 7.5 * dy - 0.5 * dy) + 1, 9 * dx - 2, 7 * dy - 1);  
  if (power_point_x <> 0) and (power_point_y <> 0) then begin
    circle(power_point_x, power_point_y, 2);
    setfontsize(10);
    drawtextcentered(power_point_x - 100, power_point_y - 30, power_point_x  + 100, power_point_y - 10, power_point_str);
    setfontsize((windowwidth div 100) + 6);
  end;
  setpenwidth(1);
end;
//checking for mouse movement and checking buttons pressed
procedure check_button;
var
  i: integer;
begin
  case public_process of 
    'play': 
      begin
        if good_reading='' then begin
        for i := 1 to 1 do
        begin
          if (moving_mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);                                                                                                                                                                                                                                                              
            if button_color[i] <> active_color then button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            if button_color[i] <> active_color then button_color[i] := deactive_color;
          end;
          if (mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            case i of
              1:
                begin
                  if (power_point_x <> 0) and (power_point_y <> 0) then begin
                    ball_sound;
                    throw_ball_bool := true;
                    power_point_x := 0;
                    power_point_y := 0;
                  end;
                end;
            end;        
          end;
        end;
        end;
        for i := 2 to 2 do
        begin
          if (moving_mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);                                                                                                                                                                                                                                                              
            if button_color[i] <> active_color then button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            if button_color[i] <> active_color then button_color[i] := deactive_color;
          end;
          if (mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            case i of
              2:
                begin
                  button_sound;
                  public_process := 'mode_choose'; 
                  good_reading:='';
                end;
            end;        
          end;
        end;
        //power panel
        if good_reading='' then begin
        if (moving_mouse_x > round(center_x - 10 * dx - 4.5 * dx)) and (moving_mouse_x < round(center_x - 10 * dx + 4.5 * dx)) and (moving_mouse_y > round(center_y + 7.5 * dy - 0.5 * dy)) and (moving_mouse_y < round(center_y + 12.5 * dy + 1.5 * dy)) then begin
          setpenwidth(2);
          setpenstyle(psdash);
          line(moving_mouse_x, moving_mouse_y, center_x - 10 * dx, moving_mouse_y);
          line(moving_mouse_x, moving_mouse_y, moving_mouse_x, round(center_y + 12.5 * dy + 1.5 * dy));
          setpenwidth(1);
          setpenstyle(pssolid);
        end;
        if (moving_mouse_x > round(center_x - 10 * dx - 4.5 * dx)) and (moving_mouse_x < round(center_x - 10 * dx + 4.5 * dx)) and (moving_mouse_y > round(center_y + 7.5 * dy - 0.5 * dy)) and (moving_mouse_y < round(center_y + 12.5 * dy + 1.5 * dy)) then begin
          //y
          str((moving_mouse_x - 6 * dx) / (1.125 * dx)-0.2, power_level_x);    {----fixed----}
          str(((center_y + 12.5 * dy + 1.5 * dy) - moving_mouse_y) / (1.4 * dy), power_level_y);
          if length(power_level_y) = 1 then power_level_y := power_level_y[1] + '.0';
          if length(power_level_y) >= 3 then power_level_y := power_level_y[1] + power_level_y[2] + power_level_y[3];
          //x
          if (length(power_level_x) >= 4) and (power_level_x[1] <> '-') then power_level_x := power_level_x[1] + power_level_x[2] + power_level_x[3];
          if (length(power_level_x) >= 4) and (power_level_x[1] = '-') then power_level_x := power_level_x[1] + power_level_x[2] + power_level_x[3] + power_level_x[4]; 
          if length(power_level_x) = 3 then power_level_x := power_level_x[1] + power_level_x[2] + power_level_x[3];
          if length(power_level_x) = 2 then power_level_x := power_level_x[1] + power_level_x[2] + '.0';
          if length(power_level_x) = 1 then power_level_x := power_level_x[1] + '.0';   
          
          if power_level_y = '0.0' then power_level_y := '0.1';
          
          power_level_str := 'x=' + power_level_x + ' y=' + power_level_y;
          //textout power over the cursor
          setfontsize(10);
          drawtextcentered(moving_mouse_x - 100, moving_mouse_y - 30, moving_mouse_x + 100, moving_mouse_y - 10, power_level_str);
          setfontsize((windowwidth div 100) + 6);
        end;
        //changing button's name
        if (mouse_x > round(center_x - 10 * dx - 4.5 * dx)) and (mouse_x < round(center_x - 10 * dx + 4.5 * dx)) and (mouse_y > round(center_y + 7.5 * dy - 0.5 * dy)) and (mouse_y < round(center_y + 12.5 * dy + 1.5 * dy)) then begin
          button_name := global_str[9] + '(' + power_level_x + ' ; ' + power_level_y + ')';
          power_point_x := mouse_x;
          power_point_y := mouse_y;
          power_point_str := power_level_str;
          ball_speed_x := strtofloat(power_level_x);
          ball_speed_y := strtofloat(power_level_y);
          calculate_trajectory;
        end;
      end;  
      if play_mode='training' then begin
      for i:=1 to 1 do begin
      if (moving_mouse_x > morse_button_x[i] - 4 * dx - morse_size[i] - dr) and (moving_mouse_x < morse_button_x[i] + 4 * dx + morse_size[i] + dr) and (moving_mouse_y > round(morse_button_y[i] - 1 * dy - morse_size[i] - dr)) and (moving_mouse_y < round(morse_button_y[i] + 1 * dy + morse_size[i] + dr)) then begin
      if morse_size[i] <> 6 then inc(morse_size[i], 2);
      morse_button_color[i] := highlighted_color;
      end
      else begin
      if morse_size[i] <> 0 then dec(morse_size[i], 2);
      if morse_button_color[i] <> active_color then morse_button_color[i] := deactive_color;
      if good_reading='table' then morse_button_color[i]:=active_color;
      end;
      if (mouse_x > morse_button_x[i] - 4 * dx - morse_size[i] - dr) and (mouse_x < morse_button_x[i] + 4 * dx + morse_size[i] + dr) and (mouse_y > round(morse_button_y[i] - 1 * dy - morse_size[i] - dr)) and (mouse_y < round(morse_button_y[i] + 1 * dy + morse_size[i] + dr)) then begin
      if good_reading = '' then begin
                                good_reading:='table';
                                t.stop;
                                continue;
                                end
                           else begin
                                good_reading:='';
                                dec(time);
                                t.start;
                                end;
                                
      end;
      end;
      end;
      end;
    'mode_choose': 
      begin
        for i := 1 to 2 do 
        begin
          if (moving_mouse_x > mode_button_x[i] - 6 * dx - mode_size[i] - dr) and (moving_mouse_x < mode_button_x[i] + 6 * dx + mode_size[i] + dr) and (moving_mouse_y > mode_button_y[i] - 6 * dy - mode_size[i] - dr) and (moving_mouse_y < mode_button_y[i] + 6 * dy + mode_size[i] + dr) then begin
            if mode_size[i] <> 6 then inc(mode_size[i], 2);
            mode_button_color[i] := highlighted_color;
          end
          else begin
            if mode_size[i] <> 0 then dec(mode_size[i], 2);
            mode_button_color[i] := deactive_color;
          end;
          if (mouse_x > mode_button_x[i] - 6 * dx - mode_size[i] - dr) and (mouse_x < mode_button_x[i] + 6 * dx + mode_size[i] + dr) and (mouse_y > mode_button_y[i] - 6 * dy - mode_size[i] - dr) and (mouse_y < mode_button_y[i] + 6 * dy + mode_size[i] + dr) then begin
            case i of
              1: 
                begin
                  button_sound;
                  public_process := 'play';
                  play_mode := 'usual';
                end;
              2: 
                begin
                  button_sound;
                  public_process := 'play';
                  play_mode := 'training';
                end;
            end;
          end;
        end;
        for i := 2 to 2 do 
        begin
          if (moving_mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (moving_mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (moving_mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (moving_mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            if size[i] <> 6 then inc(size[i], 2);                                                                                                                                                                                                                                                              
            if button_color[i] <> active_color then button_color[i] := highlighted_color;
          end
          else begin
            if size[i] <> 0 then dec(size[i], 2);
            if button_color[i] <> active_color then button_color[i] := deactive_color;
          end;
          if (mouse_x > round(button_x[i] - 4.5 * dx - size[i] - dr)) and (mouse_x < round(button_x[i] + 4.5 * dx + size[i] + dr)) and (mouse_y > round(button_y[i] - 1.5 * dy - size[i] - dr)) and (mouse_y < round(button_y[i] + 1.5 * dy + size[i] + dr)) then begin
            case i of
              2:
                begin
                  button_sound;
                  public_process := 'menu'; 
                end;
            end;        
          end;
        end;  
      end;
  end;
end;
//drawing upper window? that shows user his location in the game
procedure mid_window(str: string);
begin
  rectangle(center_x - 4 * dx - dr, center_y - 16 * dy - dr, center_x + 4 * dx + dr, center_y - 14 * dy + dr);
  setbrushcolor(location_window_color);
  rectangle(center_x - 4 * dx, center_y - 16 * dy, center_x + 4 * dx, center_y - 14 * dy);
  setbrushcolor(color_2);
  setbrushstyle(bsclear);
  drawtextcentered(center_x - 4 * dx, center_y - 16 * dy, center_x + 4 * dx, center_y - 14 * dy, str);
  setbrushstyle(bssolid);
end;
//drawing upper window, that shows user morse table
procedure morse_button(str:string);
begin
  if play_mode='training' then begin
  rectangle(morse_button_x[1]-4*dx - dr, round(morse_button_y[1]-1*dy - dr), morse_button_x[1]+4*dx + dr,round(morse_button_y[1]+1*dy + dr));
  setbrushcolor(morse_button_color[1]);
  rectangle(morse_button_x[1]-4*dx, round(morse_button_y[1]-1*dy), morse_button_x[1]+4*dx, round(morse_button_y[1]+1*dy));
  setbrushcolor(color_2);
  setbrushstyle(bsclear);
  drawtextcentered(morse_button_x[1]-4*dx, round(morse_button_y[1]-1*dy), morse_button_x[1]+4*dx, round(morse_button_y[1]+1*dy), str);
  setbrushstyle(bssolid);
  end;
end;
//drawing buttons
procedure button(x, y, size: integer; text: string; button_color: color);
begin
  rectangle(round(x - 4.5 * dx - size - dr), round(y - 1.5 * dy - size - dr), round(x + 4.5 * dx + size + dr), round(y + 1.5 * dy + size + dr));
  setbrushcolor(button_color);
  fillrectangle(round(x - 4.5 * dx - size), round(y - 1.5 * dy - size), round(x + 4.5 * dx + size), round(y + 1.5 * dy + size));
  setbrushcolor(color_2);
  rectangle(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size));
  setbrushstyle(bsclear);
  drawtextcentered(round(x - 3.5 * dx - size), round(y - 0.5 * dy - size), round(x + 3.5 * dx + size), round(y + 0.5 * dy + size), text);
  setbrushstyle(bssolid);
end;
//drawing mode buttons
procedure mode_button(x, y, size: integer; text: string; button_color: color; button_type : string);
begin
  rectangle(x - 6 * dx - size - dr, y - 6 * dy - size - dr, x + 6 * dx + size + dr, y + 6 * dy + size + dr);
  setbrushcolor(button_color);
  fillrectangle(x - 6 * dx - size, y - 6 * dy - size, x + 6 * dx + size, y + 6 * dy + size);
  setbrushcolor(color_2);
  rectangle(x - 5 * dx - size, y - 5 * dy - size, x + 5 * dx + size, y + 5 * dy + size);
  setbrushstyle(bsclear);
  drawtextcentered(x - 5 * dx - size, y - 5 * dy - size, x + 5 * dx + size, y + size, text);
  case button_type of 
  'left' : begin
           rectangle(round(x - 3.5 * dx)-dr, round(y)-dr,round(x - 1.5 * dx)+dr, round(y+4*dy)+dr);
           rectangle(round(x + 1.5 * dx)-dr, round(y)-dr,round(x + 3.5 * dx)+dr, round(y+4*dy)+dr);
           
           rectangle(round(x - 3.5 * dx), round(y),round(x - 1.5 * dx), round(y+4*dy));
           rectangle(round(x + 1.5 * dx), round(y),round(x + 3.5 * dx), round(y+4*dy));
           indicate_pic[1].Draw(round(x - 3.5 * dx)+1, round(y)+1, round(2 * dx )- 2, round(4 * dy )- 2);
           indicate_pic[4].Draw(round(x + 1.5 * dx)+1, round(y)+1, round(2 * dx )- 2, round(4 * dy )- 2);
           end;
  'right' : begin
            rectangle(round(x - 3.5 * dx)-dr, round(y)-dr,round(x - 1.5 * dx)+dr, round(y+4*dy)+dr);
            rectangle(round(x + 1.5 * dx)-dr, round(y)-dr,round(x + 3.5 * dx)+dr, round(y+4*dy)+dr);
            
            rectangle(round(x - 3.5 * dx), round(y),round(x - 1.5 * dx), round(y+4*dy));
            rectangle(round(x + 1.5 * dx), round(y),round(x + 3.5 * dx), round(y+4*dy));
            indicate_pic[2].Draw(round(x - 3.5 * dx)+1, round(y)+1, round(2 * dx )- 2, round(4 * dy )- 2);
            indicate_pic[3].Draw(round(x + 1.5 * dx)+1, round(y)+1, round(2 * dx )- 2, round(4 * dy )- 2);
            end;
          
  end;
  setbrushstyle(bssolid);
end;
//drawing window of choosing play mode
procedure mode_choose;
var
  i: integer;
begin
  public_process := 'mode_choose';
  for i := 1 to 2 do 
  begin
    mode_size[i] := 0;
    mode_button_color[i] := deactive_color;
  end;
  for i := 1 to 2 do 
  begin
    size[i] := 0;
    button_color[i] := deactive_color;
  end;
  mode_button_x[1] := center_x - 8 * dx;
  mode_button_y[1] := center_y;
  mode_button_x[2] := center_x + 8 * dx;
  mode_button_y[2] := center_y;
  lockdrawing;
  repeat
    clearwindow(background_color);
    mid_window(global_str[46]);
    mode_button(mode_button_x[1], mode_button_y[1], mode_size[1], global_str[44], mode_button_color[1],'left');
    mode_button(mode_button_x[2], mode_button_y[2], mode_size[2], global_str[45], mode_button_color[2],'right');
    button(button_x[2], button_y[2], size[2], global_str[10], button_color[2]);
    onmouse;
    check_button;
    clear_mouse_xy;
    redraw;
  until public_process <> 'mode_choose';
end;
//play
procedure play;
var
  i: integer;
begin
  fill_str;
  get_options;
  get_stats;
  round_money := 0;
  rewrite_round_money;
  initialize_gameprocess;
  game_start := true;
  phrase_complete := true;
  letter_complete := false;
  throw_ball_bool := false;
  button_name := global_str[8];
  button_color[1] := deactive_color;
  button_color[2] := deactive_color;
  good_reading:='';
  size[1] := 0;
  size[2] := 0;
  morse_size[1]:=0;
  morse_button_color[1]:=deactive_color;
  power_point_x := 0;
  power_point_y := 0;  
  if options_str[5] = 'YES' then wind_speed := random(-3, 3)
  else wind_speed := 0;
  wind_change := wind_speed;  
  lockdrawing;
  letter_panel;
  get_money;
  round_money := 0;
  random_objects;
  repeat
    clearwindow(background_color);  
    if play_mode = 'usual' then mid_window(global_str[44]);
    if play_mode = 'training' then mid_window(global_str[45]);
    morse_button(global_str[47]);
    rectangle(center_x - 14 * dx, center_y - 13 * dy, center_x + 14 * dx, center_y + 6 * dy);
    if good_reading='table' then begin
                                 rectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 6 * dy - dr);
                                 morse_pic.Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - dr * 2 - 2, 19 * dy - dr * 2 - 2);
                                 end
                            else pic[5].Draw(center_x - 14 * dx + dr + 1, center_y - 13 * dy + dr + 1, 28 * dx - dr * 2 - 2, 19 * dy - dr * 2 - 2);
    button(button_x[1], button_y[1], size[1], button_name, button_color[1]);
    button(button_x[2], button_y[2], size[2], global_str[10], button_color[2]);
    if good_reading='' then begin
    for i := 1 to 4 do
    begin
      drawrectangle(center_x - 14 * dx + dr, center_y - 13 * dy + dr, center_x + 14 * dx - dr, center_y + 6 * dy - dr);
      pic[6].Draw(goal_x[i] - round(3 * dy) + 1, goal_y[i] - round(1.5 * dy) + 1, 6 * dy - 2, 3 * dy - 2);
      setfontsize((windowwidth div 100) + 20);
      drawtextcentered(goal_x[i] - round(3 * dy), goal_y[i] - round(1.5 * dy), goal_x[i] + round(3 * dy), goal_y[i] + round(1.5 * dy), goal_str[i]);
      setfontsize((windowwidth div 100) + 6);
    end; 
    if (power_point_x <> 0) and (power_point_y <> 0) then build_trajectory;
    wind_timer_money_panel;
    end;
    power_panel;
    letter_panel;
    if good_reading='' then pic[7].Draw(ball_x - dy + 1, ball_y - dy + 1, 2 * dy - 2, 2 * dy - 2);
    if game_start = true then begin
      occasions('start');
      game_start := false;
      time := 60;
      t := timer.create(1000, dectimer); 
      t.start;
    end;
    if play_mode = 'usual' then begin
      if time = 0 then begin
        t.stop;
        rewrite_round_money;  
        occasions('stop');
        round_money := 0;
        rewrite_round_money;
        phrase_complete := true;
        letter_panel;
        for i := 1 to 1000 do 
        begin
          traj_x[i] := 0;
          traj_y[i] := 0;
        end;
        if options_str[5] = 'YES' then wind_speed := random(-3, 3)
        else wind_speed := 0;  
        wind_change := wind_speed;
        rewrite_money;
        random_objects;
      end;
    end;    
    onmouse;
    check_button; 
    if throw_ball_bool = true then begin
      throw_ball;
      power_level_x := '';
      power_level_y := '';
    end;
    clear_mouse_xy;
    redraw;
  until public_process <> 'play';
  unlockdrawing;
  t.stop;
end;

procedure main_play;
begin
  public_process := 'mode_choose';
  fill_str;
  get_options;
  get_stats;
  initialize_gameprocess;
  repeat
    case public_process of
      'play': play;
      'mode_choose': mode_choose;
    end; 
  until public_process = 'menu';  
  unlockdrawing;
  clear_mouse_xy;
end;

{----------------------------------------------------begin--------------------------------------------------}
begin
  initialize_gameprocess;
  setfontsize((windowwidth div 100) + 6);
end.