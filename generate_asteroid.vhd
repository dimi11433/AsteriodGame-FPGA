library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity asteroid_gen is 
    port(
        clk, reset: in std_logic;
        pixel_tick : in std_logic;
        video_on : in std_logic;
        pixel_x : in std_logic_vector(9 downto 0);
        pixel_y : in std_logic_vector(9 downto 0);
        graph_rgb : out std_logic_vector(2 downto 0)
    );


end asteroid_gen; 

architecture asteroids of asteroid_gen is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant ASTEROID_SIZE_2 : integer := 10;
    constant ASTEROID_SIZE_3 : integer := 15;
    constant ASTEROID_SIZE_4 : integer := 20;
    constant ASTEROID_SIZE_5 : integer := 25;

    constant ASTEROID_DY : integer := 1;
    constant ASTEROID_DX : integer := 1;

    signal pix_x, pix_y : unsigned(9 downto 0);

    signal asteroid_rom_bit : std_logic_vector(1 downto 0);

    type asteroid_id is record 
        asteroid_x_start : unsigned(9 downto 0);
        asteroid_x_end : unsigned(9 downto 0);
        asteroid_y_top : unsigned(9 downto 0);
        asteroid_y_bottom : unsigned(9 downto 0);
    end record asteroid_id;

    type asteroid_mov is record
        asteroid_x_start_next : unsigned(9 downto 0);
        asteroid_y_top_next : unsigned(9 downto 0);
    end record asteroid_mov;

    --we create an array of records which store the asteroids size aka ID
    type  asteroid_id_arry is array (1 downto 0) of asteroid_id;
    --create an array of records which store the movements of each asteroid
    type asteroid_mov_arry is array (1 downto 0) of asteroid_mov;

    signal asteroid_on : std_logic_vector(1 downto 0);

    signal asteroid_colour : std_logic_vector(2 downto 0);

    signal refresh_screen : std_logic;

    signal collision_with_asteroid, collision_with_alien : std_logic;

    signal collision_with_asteroid_happened : std_logic;

    --asteroid image
    type rom_type_10 is array(0 downto 9) of std_logic_vector(0 downto 9);
    constant ASTEROID_ROM_1 : rom_type_10 := (
        "0011111100",
        "0111111110",
        "1111111111",
        "1111111111",
        "1111111111",
        "1111111111",
        "1111111111",
        "1111111111",
        "0111111110",
        "0011111100"
    );

    type rom_type_15 is array(0 downto 14) of std_logic_vector(0 downto 14);
    constant ASTEROID_ROM_2 : rom_type_15 := (





    
    );






end asteroids;