library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity game_over_graph is
    port (
        clk, reset : in std_logic;
        pixel_x, pixel_y : in unsigned(9 downto 0);
        game_over : in std_logic;
        text_on : out std_logic
    );
end game_over_graph;

architecture game_over_arch of game_over_graph is
    constant SCREEN_WIDTH    : integer := 640;
    constant SCREEN_HEIGHT   : integer := 480;
    constant CHAR_WIDTH      : integer := 8;
    constant CHAR_HEIGHT     : integer := 8;
    constant TEXT_LENGTH     : integer := 9;
    constant TEXT_WIDTH      : integer := CHAR_WIDTH * TEXT_LENGTH;
    constant TEXT_HEIGHT     : integer := CHAR_HEIGHT;
    constant START_X         : integer := (SCREEN_WIDTH - TEXT_WIDTH) / 2;
    constant START_Y         : integer := (SCREEN_HEIGHT - TEXT_HEIGHT) / 2;

    type text_array_t is array(0 to TEXT_LENGTH-1) of std_logic_vector(7 downto 0);
    constant TEXT_ARRAY : text_array_t := (
        0 => x"10", -- 'g'
        1 => x"0A", -- 'a'
        2 => x"16", -- 'm'
        3 => x"0E", -- 'e'
        4 => x"FF", -- space
        5 => x"18", -- 'o'
        6 => x"1F", -- 'v'
        7 => x"0E", -- 'e'
        8 => x"1B"  -- 'r'
    );

    component get_character_rom
        port (
            char_addr : in  std_logic_vector(7 downto 0);
            char_data : out char_bitmap
        );
    end component;

    signal char_data    : char_bitmap;
    signal char_index   : std_logic_vector(7 downto 0);
    signal local_x      : integer range 0 to SCREEN_WIDTH;
    signal local_y      : integer range 0 to SCREEN_HEIGHT;
    signal in_text_area : std_logic;
    signal char_pos     : integer range 0 to TEXT_LENGTH-1;
    signal char_x       : integer range 0 to CHAR_WIDTH-1;
    signal char_y       : integer range 0 to CHAR_HEIGHT-1;
    signal current_bit  : std_logic;
begin
    -- Compute coordinates relative to the top-left of the centered text block
    local_x <= to_integer(pixel_x) - START_X;

    -- Determine if the current pixel is within the game over text area when game_over is active
    in_text_area <= '1' when (game_over = '1' and
                              to_integer(pixel_x) >= START_X and to_integer(pixel_x) < START_X + TEXT_WIDTH and
                              to_integer(pixel_y) >= START_Y and to_integer(pixel_y) < START_Y + TEXT_HEIGHT)
                    else '0';

    -- Calculate which character in the message this pixel falls into
    char_pos <= local_x / CHAR_WIDTH;
    -- Calculate the horizontal offset (column) of the pixel within the character bitmap
    char_x   <= local_x mod CHAR_WIDTH;
    -- Calculate the vertical offset (row) of the pixel within the character bitmap
    char_y   <= local_y;  -- row within character

    -- Select the ROM index for the current character or zero when outside text area
    char_index <= TEXT_ARRAY(char_pos) when in_text_area = '1' else (others => '0');

    -- Fetch the 8x8 bitmap data for the selected character index
    char_rom_inst : get_character_rom
        port map (
            char_addr => char_index,
            char_data => char_data
        );

    -- Extract the specific bit for this pixel from the character bitmap
    current_bit <= char_data(char_y)(char_x);

    -- Output text_on high only when inside the text area and the bitmap bit is set
    text_on <= '1' when (in_text_area = '1' and current_bit = '1') else '0';
end architecture game_over_arch;
