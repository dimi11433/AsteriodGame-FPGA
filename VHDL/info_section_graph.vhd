library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity info_section_graph is
    port (
        clk, reset : in std_logic;
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
        refresh_screen : in std_logic;
        collision : in std_logic;
        number_of_lives : in unsigned(1 downto 0);
        info_section_on : out std_logic
    );
end info_section_graph;

architecture behavioral of info_section_graph is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant INFO_SECTION_BOTTOM : integer := 42;
    constant INFO_SECTION_TOP : integer := 40;
    constant INFO_SECTION_RIGHT : integer := 102;
    constant INFO_SECTION_LEFT : integer := 100;

    signal left_bar_on, bottom_bar_on, text_on : std_logic;

    signal fetch_character_addr : std_logic_vector(7 downto 0);

    signal character_rom : char_bitmap;

    signal text_rom_bit : std_logic;

    signal text_y_top, text_x_start, text_y_bottom, text_x_end : unsigned(9 downto 0);

begin
    text_y_top <= to_unsigned(10, 10);
    text_x_start <= to_unsigned(10, 10);
    text_y_bottom <= to_unsigned(18, 10);
    text_x_end <= to_unsigned(18, 10);
    left_bar_on <= '1' when (pixel_x >= INFO_SECTION_LEFT and pixel_x <= INFO_SECTION_RIGHT) and
         (pixel_y >= to_unsigned(0, 10) and pixel_y <= INFO_SECTION_BOTTOM) else
         '0';

    bottom_bar_on <= '1' when (pixel_x >= to_unsigned(0, 10) and pixel_x <= INFO_SECTION_RIGHT) and
         (pixel_y >= INFO_SECTION_TOP and pixel_y <= INFO_SECTION_BOTTOM) else
         '0';

    text_rom_bit <= character_rom(to_integer(pixel_y) - to_integer(text_y_top))(to_integer(pixel_x) - to_integer(text_x_start));

    text_on <= '1' when (pixel_x >= text_x_start and pixel_x <= text_x_end) and
        (pixel_y >= text_y_top and pixel_y <= text_y_bottom) and (text_rom_bit = '1') else
        '0';

    info_section_on <= bottom_bar_on or left_bar_on or text_on;

    get_character_rom_unit : entity work.get_character_rom
        port map (
            char_addr => fetch_character_addr,
            char_data => character_rom
        );

    -- get the character address from the number of lives
    process(clk, reset)
    begin
        if reset = '1' then
            fetch_character_addr <= (others => '0');
        elsif rising_edge(clk) then
            if refresh_screen = '1' then
                fetch_character_addr <= std_logic_vector(to_unsigned(to_integer(number_of_lives), 8));
            end if;
        end if;
    end process;

    -- display the rom
    
end behavioral;
