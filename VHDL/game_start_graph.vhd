library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity game_start_graph is
    port (
        clk : in std_logic;
        reset : in std_logic;
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
        enable : in std_logic;
        text_on : out std_logic
    );
end entity game_start_graph;

architecture rtl of game_start_graph is
    -- One signal per line
    signal line1_on, line2_on, line3_on, line4_on, line5_on, line6_on : std_logic;

    type vader_bitmap_t is array(31 to 0) of std_logic_vector(31 downto 0);
    constant DARK_VADER_BITMAP : vader_bitmap_t := (
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000010100000000000000",
        "00000000000011110111100000000000",
        "00000000001111110111111000000000",
        "00000000011111110111111100000000",
        "00000000111111110111111110000000",
        "00000000111111110111111110000000",
        "00000000011111110111111110000000",
        "00000001101111110111111011000000",
        "00000001110011110111110111100000",
        "00000011111101110111001111100000",
        "00000000011100110110011100000000",
        "00000001111111110011111111000000",
        "00000011001110110110111001100000",
        "00000010111111110111111110100000",
        "00000110100000010100000011110000",
        "00000101100000000000000001010000",
        "00000111100000000000000001100000",
        "00000111100000000000000011111000",
        "00001111111111100011111111111000",
        "00001111100000001000000011011000",
        "00001110111111011101111110011000",
        "00001110111101001001011110111100",
        "00001000111011000001110110001000",
        "00000000010110000000110100000000",
        "00000000011010000000101100000000",
        "00000000001100000000011000000000",
        "00000000001000000000001000000000",
        "00000000000101111110010000000000",
        "00000000000100111110010000000000",
        "00000000000000000000000000000000"
    );

    constant VADER_SIZE : integer := 32;
    constant VADER_X_START : integer := 224;
    constant VADER_Y_TOP : integer := 200;
    constant VADER_X_END : integer := VADER_X_START + VADER_SIZE - 1;
    constant VADER_Y_BOTTOM : integer := VADER_Y_TOP + VADER_SIZE - 1;

    signal vader_on, vader_rom_bit : std_logic;
begin
    VADER_Y_BOTTOM <= VADER_Y_TOP + VADER_SIZE - 1;
    VADER_X_END <= VADER_X_START + VADER_SIZE - 1;
    vader_rom_bit <= DARK_VADER_BITMAP(to_integer(pixel_y - VADER_Y_TOP))(to_integer(pixel_x - VADER_X_START));
    vader_on <= '1' when (pixel_x >= VADER_X_START and pixel_x <= VADER_X_END) and (pixel_y >= VADER_Y_TOP and pixel_y <= VADER_Y_BOTTOM) and vader_rom_bit = '1' else
        '0';

    -------------------------------------------------------------------
    -- Line 1: "Once upon a time, there was a spaceship..."
    -------------------------------------------------------------------
    line1_disp : entity work.display_text
        generic map(
            TEXT_LENGTH => 42,
            TEXT_ARRAY => (
            0 => x"32", -- 'O' (index 50)
            1 => x"17", -- 'n' (23)
            2 => x"0C", -- 'c' (12)
            3 => x"0E", -- 'e' (14)
            4 => x"FF", -- ' ' (space)
            5 => x"1E", -- 'u' (30)
            6 => x"19", -- 'p' (25)
            7 => x"18", -- 'o' (24)
            8 => x"17", -- 'n' (23)
            9 => x"FF", -- ' '
            10 => x"0A", -- 'a' (10)
            11 => x"FF", -- ' '
            12 => x"1D", -- 't' (29)
            13 => x"12", -- 'i' (18)
            14 => x"16", -- 'm' (22)
            15 => x"0E", -- 'e' (14)
            16 => x"3E", -- ',' (62)
            17 => x"FF", -- ' '
            18 => x"1D", -- 't' (29)
            19 => x"11", -- 'h' (17)
            20 => x"0E", -- 'e' (14)
            21 => x"1B", -- 'r' (27)
            22 => x"0E", -- 'e' (14)
            23 => x"FF", -- ' '
            24 => x"20", -- 'w' (32)
            25 => x"0A", -- 'a' (10)
            26 => x"1C", -- 's' (28)
            27 => x"FF", -- ' '
            28 => x"0A", -- 'a' (10)
            29 => x"FF", -- ' '
            30 => x"1C", -- 's' (28)
            31 => x"19", -- 'p' (25)
            32 => x"0A", -- 'a' (10)
            33 => x"0C", -- 'c' (12)
            34 => x"0E", -- 'e' (14)
            35 => x"1C", -- 's' (28)
            36 => x"11", -- 'h' (17)
            37 => x"12", -- 'i' (18)
            38 => x"19", -- 'p' (25)
            39 => x"3F", -- '.' (63)
            40 => x"3F", -- '.'
            41 => x"3F" -- '.'
            ),
            START_Y => 50
        )
        port map(
            clk => clk,
            reset => reset,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            enable => enable,
            text_on => line1_on
        );

    -------------------------------------------------------------------
    -- Line 2: "Traveling from earth to Neptune"
    -------------------------------------------------------------------
    line2_disp : entity work.display_text
        generic map(
            TEXT_LENGTH => 31,
            TEXT_ARRAY => (
            0 => x"37", -- 'T' (55)
            1 => x"1B", -- 'r' (27)
            2 => x"0A", -- 'a' (10)
            3 => x"1F", -- 'v' (31)
            4 => x"0E", -- 'e' (14)
            5 => x"15", -- 'l' (21)
            6 => x"12", -- 'i' (18)
            7 => x"17", -- 'n' (23)
            8 => x"10", -- 'g' (16)
            9 => x"FF", -- ' '
            10 => x"0F", -- 'f' (15)
            11 => x"1B", -- 'r' (27)
            12 => x"18", -- 'o' (24)
            13 => x"16", -- 'm' (22)
            14 => x"FF", -- ' '
            15 => x"0E", -- 'e' (14)
            16 => x"0A", -- 'a' (10)
            17 => x"1B", -- 'r' (27)
            18 => x"1D", -- 't' (29)
            19 => x"11", -- 'h' (17)
            20 => x"FF", -- ' '
            21 => x"1D", -- 't' (29)
            22 => x"18", -- 'o' (24)
            23 => x"FF", -- ' '
            24 => x"31", -- 'N' (49)
            25 => x"0E", -- 'e' (14)
            26 => x"19", -- 'p' (25)
            27 => x"1D", -- 't' (29)
            28 => x"1E", -- 'u' (30)
            29 => x"17", -- 'n' (23)
            30 => x"0E" -- 'e' (14)
            ),
            START_Y => 72 -- 50 + CHAR_HEIGHT + spacing
        )
        port map(
            clk => clk,
            reset => reset,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            enable => enable,
            text_on => line2_on
        );

    -------------------------------------------------------------------
    -- Line 3: "While going through the asteroid belt"
    -------------------------------------------------------------------
    line3_disp : entity work.display_text
        generic map(
            TEXT_LENGTH => 37,
            TEXT_ARRAY => (
            0 => x"3A", -- 'W' (58)
            1 => x"11", -- 'h' (17)
            2 => x"12", -- 'i' (18)
            3 => x"15", -- 'l' (21)
            4 => x"0E", -- 'e' (14)
            5 => x"FF", -- ' '
            6 => x"10", -- 'g' (16)
            7 => x"18", -- 'o' (24)
            8 => x"12", -- 'i' (18)
            9 => x"17", -- 'n' (23)
            10 => x"10", -- 'g' (16)
            11 => x"FF", -- ' '
            12 => x"1D", -- 't' (29)
            13 => x"11", -- 'h' (17)
            14 => x"1B", -- 'r' (27)
            15 => x"18", -- 'o' (24)
            16 => x"1E", -- 'u' (30)
            17 => x"10", -- 'g' (16)
            18 => x"11", -- 'h' (17)
            19 => x"FF", -- ' '
            20 => x"1D", -- 't' (29)
            21 => x"11", -- 'h' (17)
            22 => x"0E", -- 'e' (14)
            23 => x"FF", -- ' '
            24 => x"0A", -- 'a' (10)
            25 => x"1C", -- 's' (28)
            26 => x"1D", -- 't' (29)
            27 => x"0E", -- 'e' (14)
            28 => x"1B", -- 'r' (27)
            29 => x"18", -- 'o' (24)
            30 => x"12", -- 'i' (18)
            31 => x"0D", -- 'd' (13)
            32 => x"FF", -- ' '
            33 => x"0B", -- 'b' (11)
            34 => x"0E", -- 'e' (14)
            35 => x"15", -- 'l' (21)
            36 => x"1D" -- 't' (29)
            ),
            START_Y => 94
        )
        port map(
            clk => clk,
            reset => reset,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            enable => enable,
            text_on => line3_on
        );

    -------------------------------------------------------------------
    -- Line 4: "It encountered an alien"
    -------------------------------------------------------------------
    line4_disp : entity work.display_text
        generic map(
            TEXT_LENGTH => 23,
            TEXT_ARRAY => (
            0 => x"2C", -- 'I' (44)
            1 => x"1D", -- 't' (29)
            2 => x"FF", -- ' '
            3 => x"0E", -- 'e' (14)
            4 => x"17", -- 'n' (23)
            5 => x"0C", -- 'c' (12)
            6 => x"18", -- 'o' (24)
            7 => x"1E", -- 'u' (30)
            8 => x"17", -- 'n' (23)
            9 => x"1D", -- 't' (29)
            10 => x"0E", -- 'e' (14)
            11 => x"1B", -- 'r' (27)
            12 => x"0E", -- 'e' (14)
            13 => x"0D", -- 'd' (13)
            14 => x"FF", -- ' '
            15 => x"0A", -- 'a' (10)
            16 => x"17", -- 'n' (23)
            17 => x"FF", -- ' '
            18 => x"0A", -- 'a' (10)
            19 => x"15", -- 'l' (21)
            20 => x"12", -- 'i' (18)
            21 => x"0E", -- 'e' (14)
            22 => x"17" -- 'n' (23)
            ),
            START_Y => 116
        )
        port map(
            clk => clk,
            reset => reset,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            enable => enable,
            text_on => line4_on
        );

    -------------------------------------------------------------------
    -- Line 5: "Get through the asteroid belt safely"
    -------------------------------------------------------------------
    line5_disp : entity work.display_text
        generic map(
            TEXT_LENGTH => 36,
            TEXT_ARRAY => (
            0 => x"2A", -- 'G' (42)
            1 => x"0E", -- 'e' (14)
            2 => x"1D", -- 't' (29)
            3 => x"FF", -- ' '
            4 => x"1D", -- 't' (29)
            5 => x"11", -- 'h' (17)
            6 => x"1B", -- 'r' (27)
            7 => x"18", -- 'o' (24)
            8 => x"1E", -- 'u' (30)
            9 => x"10", -- 'g' (16)
            10 => x"11", -- 'h' (17)
            11 => x"FF", -- ' '
            12 => x"1D", -- 't' (29)
            13 => x"11", -- 'h' (17)
            14 => x"0E", -- 'e' (14)
            15 => x"FF", -- ' '
            16 => x"0A", -- 'a' (10)
            17 => x"1C", -- 's' (28)
            18 => x"1D", -- 't' (29)
            19 => x"0E", -- 'e' (14)
            20 => x"1B", -- 'r' (27)
            21 => x"18", -- 'o' (24)
            22 => x"12", -- 'i' (18)
            23 => x"0D", -- 'd' (13)
            24 => x"FF", -- ' '
            25 => x"0B", -- 'b' (11)
            26 => x"0E", -- 'e' (14)
            27 => x"15", -- 'l' (21)
            28 => x"1D", -- 't' (29)
            29 => x"FF", -- ' '
            30 => x"1C", -- 's' (28)
            31 => x"0A", -- 'a' (10)
            32 => x"0F", -- 'f' (15)
            33 => x"0E", -- 'e' (14)
            34 => x"15", -- 'l' (21)
            35 => x"22" -- 'y' (34)
            ),
            START_Y => 138
        )
        port map(
            clk => clk,
            reset => reset,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            enable => enable,
            text_on => line5_on
        );

    -------------------------------------------------------------------
    -- Line 6: "May the force be with you!"
    -------------------------------------------------------------------
    line6_disp : entity work.display_text
        generic map(
            TEXT_LENGTH => 26,
            TEXT_ARRAY => (
            0  => x"30", -- 'M' (48)
            1  => x"0A", -- 'a' (10)
            2  => x"22", -- 'y' (34)
            3  => x"FF", -- ' '
            4  => x"1D", -- 't' (29)
            5  => x"11", -- 'h' (17)
            6  => x"0E", -- 'e' (14)
            7  => x"FF", -- ' '
            8  => x"29", -- 'F' (41)
            9  => x"18", -- 'o' (24)
            10 => x"1B", -- 'r' (27)
            11 => x"0C", -- 'c' (12)
            12 => x"0E", -- 'e' (14)
            13 => x"FF", -- ' '
            14 => x"0B", -- 'b' (11)
            15 => x"0E", -- 'e' (14)
            16 => x"FF", -- ' '
            17 => x"20", -- 'w' (32)
            18 => x"12", -- 'i' (18)
            19 => x"1D", -- 't' (29)
            20 => x"11", -- 'h' (17)
            21 => x"FF", -- ' '
            22 => x"22", -- 'y' (34)
            23 => x"18", -- 'o' (24)
            24 => x"1E"  -- 'u' (30)
            25 => x"40"  -- '!' (64)
            ),
            START_Y => 160
        )
        port map(
            clk     => clk,
            reset   => reset,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            enable  => enable,
            text_on => line6_on
        );

    -- Combine all lines into one text_on
    text_on <= line1_on or line2_on or line3_on or line4_on or line5_on or line6_on or vader_on;

end architecture rtl;