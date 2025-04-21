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
    constant INFO_SECTION_RIGHT : integer := 152;
    constant INFO_SECTION_LEFT : integer := 150;

    signal left_bar_on, bottom_bar_on, text_on : std_logic;

    signal fetch_character_addr : std_logic_vector(7 downto 0);

    signal character_rom : char_bitmap;

    signal text_rom_bit : std_logic;

    signal text_y_top, text_x_start, text_y_bottom, text_x_end : unsigned(9 downto 0);

    -- Signal to capture text-on from display_text for the static suffix
    signal lives_left_text_on : std_logic;

begin
    text_y_top <= to_unsigned(10, 10);
    text_x_start <= to_unsigned(10, 10);
    text_y_bottom <= to_unsigned(18, 10);
    text_x_end <= to_unsigned(18, 10);
    -- Render left bar of info section: vertical bar at defined X and full Y range
    left_bar_on <= '1' when (pixel_x >= INFO_SECTION_LEFT and pixel_x <= INFO_SECTION_RIGHT) and
        (pixel_y >= to_unsigned(0, 10) and pixel_y <= INFO_SECTION_BOTTOM) else
        '0';

    -- Render bottom bar of info section: horizontal bar at defined Y and full X range
    bottom_bar_on <= '1' when (pixel_x >= to_unsigned(0, 10) and pixel_x <= INFO_SECTION_RIGHT) and
        (pixel_y >= INFO_SECTION_TOP and pixel_y <= INFO_SECTION_BOTTOM) else
        '0';

    -- Sample character ROM bit for current pixel within the text bounding box
    text_rom_bit <= character_rom(to_integer(pixel_y(2 downto 0) - text_y_top(2 downto 0)))(to_integer(pixel_x(2 downto 0) - text_x_start(2 downto 0)));

    -- Render text pixel: check bounding box and ROM bit to display character
    text_on <= '1' when (pixel_x >= text_x_start and pixel_x <= text_x_end) and
        (pixel_y >= text_y_top and pixel_y <= text_y_bottom) and (text_rom_bit = '1') else
        '0';

    -- Combine bars and text signals to drive the overall info section visibility
    info_section_on <= bottom_bar_on or left_bar_on or text_on or lives_left_text_on;

    get_character_rom_unit : entity work.get_character_rom
        port map(
            char_addr => fetch_character_addr,
            char_data => character_rom
        );

    -- get the character address from the number of lives
    -- Update character address each frame based on number of lives
    process (clk, reset)
    begin
        -- On reset: clear fetch_character_addr to default
        if reset = '1' then
            fetch_character_addr <= (others => '0');
        elsif rising_edge(clk) then
            -- On refresh tick: load new character address representing current number_of_lives
            if refresh_screen = '1' then
                fetch_character_addr <= std_logic_vector(to_unsigned(to_integer(number_of_lives), 8));
            end if;
        end if;
    end process;

    -- Render the static suffix " lives left"
    lives_left_display : entity work.display_text
        generic map(
            TEXT_LENGTH => 11,
            START_X => 18,
            START_Y => 10,
            TEXT_ARRAY => (
            0 => x"FF", -- ' ' (space)
            1 => x"15", -- 'l'
            2 => x"12", -- 'i'
            3 => x"1F", -- 'v'
            4 => x"0E", -- 'e'
            5 => x"1C", -- 's'
            6 => x"FF", -- ' ' (space)
            7 => x"15", -- 'l'
            8 => x"0E", -- 'e'
            9 => x"0F", -- 'f'
            10 => x"1D" -- 't'
            )
        )
        port map(
            clk => clk,
            reset => reset,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            enable => '1',
            text_on => lives_left_text_on
        );

end behavioral;