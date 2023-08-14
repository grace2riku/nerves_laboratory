defmodule ThermometersDs1631 do
  @moduledoc """
  Documentation for ThermometersDs1631.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ThermometersDs1631.hello
      :world

  """
  def hello do
    :world
  end

  require Logger
  alias Circuits.I2C
  @i2c_bus "i2c-1"
  @ds1631_i2c_addr 0x48
  @conversion_time 500

  @start_convert_command 0x51
  @read_temperature_command 0xAA
  @stop_convert_command 0x22

  def read_temperature do
    {:ok, ref} = I2C.open(@i2c_bus)

    I2C.write(ref, @ds1631_i2c_addr, <<@start_convert_command>>)
    Process.sleep(@conversion_time)
    I2C.write(ref, @ds1631_i2c_addr, <<@read_temperature_command>>)

    {:ok, <<raw_temperature::16>>} = I2C.read(ref, @ds1631_i2c_addr, 2)

    I2C.write(ref, @ds1631_i2c_addr, <<@stop_convert_command>>)
    I2C.close(ref)

    temperature = raw_temperature / 256.0
    Logger.info("Raw temperature = #{raw_temperature}, Temperature = #{temperature}")

    temperature
  end

end
