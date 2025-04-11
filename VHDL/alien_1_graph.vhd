library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alien_1_graph is
    port (
        clk, reset : in std_logic;
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
        -- btnl, btnr : in std_logic;
        -- btnu, btnd : in std_logic;
        -- btnc : in std_logic;
        refresh_screen : in std_logic;
        -- collision : in std_logic;
        active : in std_logic;
        alien_on : out std_logic
    );
end entity alien_1_graph;

architecture behavior of alien_1_graph is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant ALIEN_SIZE : integer := 24;

    constant ALIEN_DX : integer := 1;

    signal alien_rom_bit : std_logic;

    signal alien_x_start, alien_x_end : unsigned(9 downto 0);
    signal alien_y_top, alien_y_bottom : unsigned(9 downto 0);

    signal alien_x_start_next, alien_y_top_next : unsigned(9 downto 0);

    -- alien image
    type rom_type_16 is array(0 to 15) of std_logic_vector(0 to 23);
    constant ALIEN_ROM : rom_type_16 := (
        "000000110000000011000000",
        "000000001110011100000000",
        "000000001110011100000000",
        "011000111111111111000110",
        "011000111111111111000110",
        "011000111111111111000110",
        "011000110001100011000110",
        "011000110001100011000110",
        "000111111111111111111000",
        "000111111111111111111000",
        "000111111111111111111000",
        "000000111111111111000000",
        "000000111111111111000000",
        "000000001110011100000000",
        "000000001110011100000000",
        "000000001110011100000000"
    );

begin
    alien_rom_bit <= ALIEN_ROM(to_integer(pixel_y) - to_integer(alien_y_top))(to_integer(pixel_x) - to_integer(alien_x_start));

    alien_on <= '1' when (pixel_x >= alien_x_start and pixel_x <= alien_x_end) and
        (pixel_y >= alien_y_top and pixel_y <= alien_y_bottom) and (alien_rom_bit = '1') and (active = '1') else
        '0';

    -- Set the right and bottom for all the objects
    alien_x_end <= alien_x_start + ALIEN_SIZE - 1;
    alien_y_bottom <= alien_y_top + ALIEN_SIZE - 1;

    -- move the alien
    process (alien_x_start)
    begin
        if alien_x_start < to_unsigned(SCREEN_WIDTH - ALIEN_SIZE, 10) then
            alien_x_start_next <= alien_x_start + ALIEN_DX;
        else
            alien_x_start_next <= to_unsigned(0, 10);
        end if;

    end process;

    -- at reset, the alien is at the center of the screen
    process (clk, reset)
    begin
        if (reset = '1') then
            alien_x_start <= to_unsigned(SCREEN_WIDTH / 2 - ALIEN_SIZE / 2, 10);
            alien_y_top <= to_unsigned(10, 10);
        elsif (rising_edge(clk)) then
            if (refresh_screen = '1') then
                alien_x_start <= alien_x_start_next;
                alien_y_top <= alien_y_top_next;
            end if;
        end if;
    end process;
end behavior;