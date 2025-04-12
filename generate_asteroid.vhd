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
    constant ASTEROID_SIZE_3 : integer := 20;
    constant ASTEROID_SIZE_4 : integer := 30;
    constant ASTEROID_SIZE_5 : integer := 40;

    constant ASTEROID_DY : integer := 1;
    constant ASTEROID_DX : integer := 1;

    signal pix_x, pix_y : unsigned(9 downto 0);
    signal asteroid_rom_bit : std_logic_vector(1 downto 0);

    signal asteroid_x_start, asteroid_x_end : unsigned(9 downto 0);
    signal asteroid_y_top, asteroid_y_bottom : unsigned(9 downto 0);


    -- next start positions for the objects
    signal asteroid_x_start_next, asteroid_y_top_next : unsigned(9 downto 0);





end asteroids;