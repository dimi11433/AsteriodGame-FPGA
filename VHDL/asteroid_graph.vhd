library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity asteroid_graph is
    port (
        video_on : in std_logic;
        pixel_x : in std_logic_vector(9 downto 0);
        pixel_y : in std_logic_vector(9 downto 0);
        graph_rgb : out std_logic_vector(2 downto 0);
    );
end asteroid_graph;

architecture asteroid_arch of asteroid_graph is
    signal pix_x, pix_y : unsigned(9 downto 0);
    signal alien_rom_bit, spaceship_rom_bit, asteroid_rom_bit : std_logic;

    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant ALIEN_X_SIZE : integer := 12;
    constant ALIEN_Y_SIZE : integer := 8;
    constant SPACESHIP_SIZE : integer := 8;
    constant ASTEROID_SIZE : integer := 8;

    constant ALIEN_X_START : integer := SCREEN_WIDTH / 2 - ALIEN_X_SIZE / 2;
    constant ALIEN_X_END : integer := ALIEN_X_START + ALIEN_X_SIZE - 1;
    constant ALIEN_Y_TOP : integer := 10;
    constant ALIEN_Y_BOTTOM : integer := ALIEN_Y_TOP + ALIEN_Y_SIZE - 1;

    constant SPACESHIP_X_START : integer := SCREEN_WIDTH / 2 - SPACESHIP_SIZE / 2;
    constant SPACESHIP_X_END : integer := SPACESHIP_X_START + SPACESHIP_SIZE - 1;
    constant SPACESHIP_Y_TOP : integer := SCREEN_HEIGHT - 10 - SPACESHIP_SIZE;
    constant SPACESHIP_Y_BOTTOM : integer := SPACESHIP_Y_TOP + SPACESHIP_SIZE - 1;

    constant ASTEROID_X_START : integer := SCREEN_WIDTH / 2 - ASTEROID_SIZE / 2;
    constant ASTEROID_X_END : integer := ASTEROID_X_START + ASTEROID_SIZE - 1;
    constant ASTEROID_Y_TOP : integer := SCREEN_HEIGHT / 2 - ASTEROID_SIZE / 2;
    constant ASTEROID_Y_BOTTOM : integer := ASTEROID_Y_TOP + ASTEROID_SIZE - 1;

    signal alien_on, spaceship_on, asteroid_on : std_logic;
    signal alien_color, spaceship_color, asteroid_color : std_logic_vector(2 downto 0);

    -- alien image
    type rom_type_24 is array(0 to 23) of std_logic_vector(0 to 23);
    constant ALIEN_ROM : rom_type_24 := (
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
    -- spaceship image
    type rom_type_16 is array(0 to 16) of std_logic_vector(0 to 15);
    constant SPACESHIP_ROM : rom_type_16 := (
        "0000000100000000", -- tip
        "0000001110000000",
        "0000011111000000",
        "0000111111110000",
        "0011111111111100", -- body starts
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100",
        "0011111111111100", -- body ends
        "0111111111111110", -- exhaust/flame begins
        "1111111111111111",
        "0111111111111110",
        "0011111111111100" -- exhaust/flame ends
    );
    -- asteroid image
    type rom_type_8 is array(0 to 8) of std_logic_vector(0 to 8);
    constant ASTEROID_ROM : rom_type_8 := (
        "00111100",
        "01111110",
        "11111111",
        "11111111",
        "11111111",
        "11111111",
        "01111110",
        "00111100"
    );

begin
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);

    alien_rom_bit <= ALIEN_ROM(to_integer(pix_y) - ALIEN_Y_TOP)(to_integer(pix_x) - ALIEN_X_START);

    spaceship_rom_bit <= SPACESHIP_ROM(to_integer(pix_y) - SPACESHIP_Y_TOP)(to_integer(pix_x) - SPACESHIP_X_START);

    asteroid_rom_bit <= ASTEROID_ROM(to_integer(pix_y) - ASTEROID_Y_TOP)(to_integer(pix_x) - ASTEROID_X_START);

    alien_on <= '1' when (pix_x >= ALIEN_X_START and pix_x <= ALIEN_X_END) and
        (pix_y >= ALIEN_Y_TOP and pix_y <= ALIEN_Y_BOTTOM) and (alien_rom_bit = '1') else
        '0';

    spaceship_on <= '1' when (pix_x >= SPACESHIP_X_START and pix_x <= SPACESHIP_X_END) and
        (pix_y >= SPACESHIP_Y_TOP and pix_y <= SPACESHIP_Y_BOTTOM) and (spaceship_rom_bit = '1') else
        '0';

    asteroid_on <= '1' when (pix_x >= ASTEROID_X_START and pix_x <= ASTEROID_X_END) and
        (pix_y >= ASTEROID_Y_TOP and pix_y <= ASTEROID_Y_BOTTOM) and (asteroid_rom_bit = '1') else
        '0';

    alien_color <= "001";
    spaceship_color <= "010"; -- green
    asteroid_color <= "111"; -- white/greyish

    process (video_on, alien_on, spaceship_on, asteroid_on)
    begin
        if video_on = '1' then
            if alien_on = '1' then
                graph_rgb <= alien_color;
            elsif spaceship_on = '1' then
                graph_rgb <= spaceship_color;
            elsif asteroid_on = '1' then
                graph_rgb <= asteroid_color;
            else
                graph_rgb <= "000"; -- black
            end if;
        else
            graph_rgb <= "000"; -- black
        end if;
    end process;
end asteroid_arch;