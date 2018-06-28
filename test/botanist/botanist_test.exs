defmodule Botanist.BotanistTest do
  use Botanist.Case

  import Botanist

  alias Botanist.Seed

  test "seed does not repeat" do
    with_mock NaiveDateTime,
      utc_now: fn ->
        %NaiveDateTime{
          calendar: Calendar.ISO,
          day: 1,
          hour: 1,
          microsecond: {999_999, 6},
          minute: 1,
          month: 1,
          second: 1,
          year: 1
        }
      end do
      # -- Given
      #
      Repo.insert(%Seed{name: "botanist_test", inserted_at: NaiveDateTime.utc_now()})

      # -- When
      #
      {:repeat, error_msg} =
        seed do
          {:ok, "hi"}
        end

      # -- Then
      #
      seeds =
        from(s in Seed)
        |> Repo.all()

      assert length(seeds) == 1
      seed_names = Enum.map(seeds, fn s -> s.name end)
      assert Enum.member?(seed_names, "botanist_test")
      assert error_msg == "The seed botanist_test has already run."
    end
  end

  test "seed throws error" do
    # -- Given
    #

    # -- When
    #
    {:error, error_msg} =
      seed do
        throw("an error occurred")
      end

    # -- Then
    #
    assert error_msg == "an error occurred"

    expected =
      from(
        s in Seed,
        where: s.name == "another seed entry"
      )
      |> Repo.all()

    assert length(expected) == 0
  end

  test "seed raises error" do
    # -- Given
    #

    # -- When
    #
    {:error, error_msg} =
      seed do
        raise "an error occurred"
      end

    # -- Then
    #
    assert error_msg == "an error occurred"

    expected =
      from(
        s in Seed,
        where: s.name == "another seed entry"
      )
      |> Repo.all()

    assert length(expected) == 0
  end

  test "seed without explicit name" do
    # -- Given
    #

    # -- When
    #
    seed do
      {:ok, "hi"}
    end

    # -- Then
    #
    expected =
      from(s in Seed)
      |> Repo.all()

    assert length(expected) == 1
    assert Enum.at(expected, 0).name == "botanist_test"
  end
end
