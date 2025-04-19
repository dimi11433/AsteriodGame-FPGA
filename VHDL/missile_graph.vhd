library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity missile_graph is
    port (
        clk, reset : in std_logic;
        pixel_tick : in std_logic;
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
        refresh_screen : in std_logic;
        missile_x : in unsigned(9 downto 0);
        missile_y : in unsigned(9 downto 0);
        launch_missile : in std_logic;
        alien_on : in std_logic;
        asteroid_on : in std_logic;
        missile_on : out std_logic
    );
end missile_graph;
architecture missile_arch of missile_graph is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant MISSILE_SIZE : integer := 4;

    constant MISSILE_DY : integer := 1;

    constant MAX_NUMBER_OF_MISSILES : integer := 20;

    type missile_rom is array (0 to 3) of std_logic_vector(3 downto 0);
    constant MISSILE_BITMAP : missile_rom := (
        "0110", -- Row 0
        "1111", -- Row 1
        "1111", -- Row 2
        "0110" -- Row 3
    );

    type missile_single_bit_prop is array (0 to MAX_NUMBER_OF_MISSILES - 1) of std_logic;
    signal missile_rom_bit_array, missile_on_array, missile_active_array : missile_single_bit_prop;

    type missile_vector_prop is array (0 to MAX_NUMBER_OF_MISSILES - 1) of unsigned(9 downto 0);
    signal missile_x_starts, missile_x_ends, missile_y_tops, missile_y_bottoms : missile_vector_prop;

    signal missile_y_tops_next : missile_vector_prop;

    signal missile_shoot_available : unsigned(1 downto 0);
    -- register to detect rising edge of launch_missile
    signal launch_missile_reg : std_logic := '0';

begin

    process (pixel_x, pixel_y)
    begin
        for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
            missile_rom_bit_array(i) <= MISSILE_BITMAP(to_integer(pixel_y(1 downto 0) - missile_y_tops(i)(1 downto 0)))(to_integer(pixel_x(1 downto 0) - missile_x_starts(i)(1 downto 0)));
        end loop;
    end process;

    process (pixel_x, pixel_y)
    begin
        for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
            missile_x_ends(i) <= missile_x_starts(i) + to_unsigned(MISSILE_SIZE, 10);
            missile_y_bottoms(i) <= missile_y_tops(i) + to_unsigned(MISSILE_SIZE, 10);
        end loop;
    end process;

    process (pixel_x, pixel_y)
    begin
        for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
            missile_on_array(i) <= '1' when (pixel_x >= missile_x_starts(i) and pixel_x <= missile_x_ends(i)) and
            (pixel_y >= missile_y_tops(i) and pixel_y <= missile_y_bottoms(i)) and (missile_rom_bit_array(i) = '1') and (missile_active_array(i) = '1') else
            '0';
        end loop;
    end process;

    process (pixel_x, pixel_y)
    begin
        for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
            missile_y_tops_next(i) <= missile_y_tops(i) - to_unsigned(MISSILE_DY, 10);
        end loop;
    end process;

    -- move the missile
    process (clk, reset)
      variable fired_var : std_logic := '0';
    begin
        if reset = '1' then
            for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                missile_x_starts(i) <= to_unsigned(0, 10);
                missile_y_tops(i) <= to_unsigned(0, 10);
                missile_active_array(i) <= '0';
            end loop;
        elsif rising_edge(clk) then
            -- update previous state of launch_missile
            launch_missile_reg <= launch_missile;
            -- clear launch one-shot flag each cycle
            fired_var := '0';
            if launch_missile = '1' and launch_missile_reg = '0' and missile_shoot_available = "00" then
                for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                    if (missile_active_array(i) = '0') and (fired_var = '0') then
                        missile_x_starts(i) <= missile_x;
                        missile_y_tops(i) <= missile_y;
                        missile_active_array(i) <= '1';
                        fired_var := '1';
                    end if;
                end loop;
            end if;
            if refresh_screen = '1' then
                for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                    if missile_active_array(i) = '1' then
                        if missile_y_tops(i) = to_unsigned(0, 10) then
                            missile_active_array(i) <= '0';
                            missile_x_starts(i) <= to_unsigned(0, 10);
                            missile_y_tops(i) <= to_unsigned(0, 10);
                        else
                            missile_y_tops(i) <= missile_y_tops_next(i);
                        end if;
                    end if;
                end loop;
            end if;

            -- check for collision with alien or asteroid
            for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
                if (missile_active_array(i) = '1') and (alien_on = '1' or asteroid_on = '1') and (missile_on_array(i) = '1') then
                    missile_active_array(i) <= '0';
                    missile_x_starts(i) <= to_unsigned(0, 10);
                    missile_y_tops(i) <= to_unsigned(0, 10);
                end if;
            end loop;
        end if;
    end process;

    process (pixel_x, pixel_y)
    begin
        missile_on <= '0';
        for i in 0 to MAX_NUMBER_OF_MISSILES - 1 loop
            if (missile_on_array(i) = '1') then
                missile_on <= '1';
            end if;
        end loop;
    end process;

    process (clk, reset, refresh_screen)
    begin
        if reset = '1' then
            missile_shoot_available <= "00";
        elsif rising_edge(clk) then
            if refresh_screen = '1' then
                if launch_missile = '1' then
                    missile_shoot_available <= "11";
                else
                    if missile_shoot_available > 0 then
                        missile_shoot_available <= missile_shoot_available - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
end missile_arch;