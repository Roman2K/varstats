Class.new Sequel::Migration do
  def up
    create_table :bazarr_stats do
      timestamptz :time, null: false

      integer :episodes, null: false
      integer :movies, null: false
      integer :providers, null: false
    end

    self << %{SELECT create_hypertable('bazarr_stats', 'time');}
  end
end
