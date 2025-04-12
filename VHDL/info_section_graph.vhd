library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity info_section_graph is
    port (
        clk, reset : in std_logic;
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
        refresh_screen : in std_logic;
        collision : in std_logic;
        info_section_on : out std_logic
    );
end info_section_graph;

architecture behavioral of info_section_graph is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant INFO_SECTION_BOTTOM : integer := 42;
    constant INFO_SECTION_TOP : integer := 40;
    constant INFO_SECTION_RIGHT : integer := 62;
    constant INFO_SECTION_LEFT : integer := 60;

    signal left_bar_on, bottom_bar_on : std_logic;

begin
    left_bar_on <= '1' when (pixel_x >= INFO_SECTION_LEFT and pixel_x <= INFO_SECTION_RIGHT) and
         (pixel_y >= (others => '0') and pixel_y <= INFO_SECTION_BOTTOM) else
         '0';

    bottom_bar_on <= '1' when (pixel_x >= (others => '0') and pixel_x <= INFO_SECTION_RIGHT) and
         (pixel_y >= INFO_SECTION_BOTTOM and pixel_y <= INFO_SECTION_TOP) else
         '0';

    info_section_on <= bottom_bar_on or left_bar_on;
end behavioral;
