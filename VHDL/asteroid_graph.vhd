library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity asteroid_graph is
    port (
        video_on : in std_logic;
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
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
    type rom_type_12 is array(0 to 7) of std_logic_vector(0 to 11);
    constant ALIEN_ROM : rom_type_12 := (
        "000111111100",
        "011000000011",
        "101101101101",
        "101000000101",
        "101101101101",
        "100110110001",
        "011000000110",
        "000111111000"
    );
    -- spaceship image
    type rom_type_8 is array(0 to 7) of std_logic_vector(0 to 7);
    constant SPACESHIP_ROM : rom_type_8 := (
        "00011000",
        "00111100",
        "01111110",
        "11111111",
        "11111111",
        "00100100",
        "01011010",
        "10000001"
    );
    -- asteroid image
    constant ASTEROID_ROM : rom_type_8 := (
        "00011000",
        "00111100",
        "01111110",
        "11111111",
        "11111111",
        "00100100",
        "01011010",
        "10000001"
    );

    begin
    pix_x <= to_unsigned(pixel_x);
    pix_y <= to_unsigned(pixel_y);

    alien_rom_bit <= ALIEN_ROM(to_integer(pix_y) - ALIEN_Y_TOP)(to_integer(pix_x) - ALIEN_X_START);

    spaceship_rom_bit <= SPACESHIP_ROM(to_integer(pix_y) - SPACESHIP_Y_TOP)(to_integer(pix_x) - SPACESHIP_X_START);

    asteroid_rom_bit <= ASTEROID_ROM(to_integer(pix_y) - ASTEROID_Y_TOP)(to_integer(pix_x) - ASTEROID_X_START);

    alien_on <= '1' when (pixel_x >= ALIEN_X_START and pixel_x <= ALIEN_X_END) and
        (pixel_y >= ALIEN_Y_TOP and pixel_y <= ALIEN_Y_BOTTOM) and (alien_rom_bit) else
        '0';

    spaceship_on <= '1' when (pixel_x >= SPACESHIP_X_START and pixel_x <= SPACESHIP_X_END) and
        (pixel_y >= SPACESHIP_Y_TOP and pixel_y <= SPACESHIP_Y_BOTTOM) and (spaceship_rom_bit) else
        '0';

    asteroid_on <= '1' when (pixel_x >= ASTEROID_X_START and pixel_x <= ASTEROID_X_END) and
        (pixel_y >= ASTEROID_Y_TOP and pixel_y <= ASTEROID_Y_BOTTOM) and (asteroid_rom_bit) else
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