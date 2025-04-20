library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

type text_array_t is array (natural range <>) of std_logic_vector(7 downto 0);

entity display_text is
    generic (
        SCREEN_WIDTH  : integer := 640;
        SCREEN_HEIGHT : integer := 480;
        CHAR_WIDTH    : integer := 8;
        CHAR_HEIGHT   : integer := 8;
        TEXT_LENGTH   : integer := 9;
        TEXT_WIDTH    : integer := CHAR_WIDTH * TEXT_LENGTH;
        TEXT_HEIGHT   : integer := CHAR_HEIGHT;
        START_X       : integer := (SCREEN_WIDTH - TEXT_WIDTH) / 2;
        START_Y       : integer := (SCREEN_HEIGHT - TEXT_HEIGHT) / 2;
        TEXT_ARRAY    : text_array_t(0 to TEXT_LENGTH - 1)  := (
            0 => x"10", -- 'g'
            1 => x"0A", -- 'a'
            2 => x"16", -- 'm'
            3 => x"0E", -- 'e'
            4 => x"FF", -- space
            5 => x"18", -- 'o'
            6 => x"1F", -- 'v'
            7 => x"0E", -- 'e'
            8 => x"1B"  -- 'r'
        )
    );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        pixel_x  : in  unsigned(9 downto 0);
        pixel_y  : in  unsigned(9 downto 0);
        enable   : in  std_logic;
        text_on  : out std_logic
    );
end entity display_text;

architecture rtl of display_text is
    signal local_x      : integer range -TEXT_WIDTH to SCREEN_WIDTH;
    signal local_y      : integer range -TEXT_HEIGHT to SCREEN_HEIGHT;
    signal in_text_area : std_logic;
    signal char_pos     : integer range 0 to TEXT_LENGTH-1;
    signal char_x       : integer range 0 to CHAR_WIDTH-1;
    signal char_y       : integer range 0 to CHAR_HEIGHT-1;
    signal char_index   : std_logic_vector(7 downto 0);
    signal char_data    : char_bitmap;
    signal current_bit  : std_logic;
begin
    -- Compute pixel coordinates relative to text origin
    local_x <= to_integer(pixel_x) - START_X;
    local_y <= to_integer(pixel_y) - START_Y;

    -- Check if inside the text block when enabled
    in_text_area <= '1' when (enable = '1' and
                              to_integer(pixel_x) >= START_X and
                              to_integer(pixel_x) < START_X + TEXT_WIDTH and
                              to_integer(pixel_y) >= START_Y and
                              to_integer(pixel_y) < START_Y + TEXT_HEIGHT)
                    else '0';

    -- Determine character index and offsets
    char_pos <= local_x / CHAR_WIDTH;
    char_x   <= local_x mod CHAR_WIDTH;
    char_y   <= local_y;

    -- Select appropriate character code or 0 outside area
    char_index <= TEXT_ARRAY(char_pos) when in_text_area = '1' else (others => '0');

    -- Fetch character bitmap from ROM
    rom_inst : get_character_rom
        port map (
            char_addr => char_index,
            char_data => char_data
        );

    -- Extract the bitmap bit for this pixel
    current_bit <= char_data(char_y)(char_x);

    -- Assert text_on only when inside the block and bitmap bit is set
    text_on <= '1' when (in_text_area = '1' and current_bit = '1') else '0';
end architecture rtl;