require "kemal"
require "./block"

module Test::Blockchain
  blockchain = [] of NamedTuple(
    index: Int32,
    timestamp: String,
    data: String,
    hash: String,
    prev_hash: String,
    difficulty: Int32,
    nonce: String
  )

  blockchain << Block.create(0, Time.utc.to_s, "Data for the genesis block", "")

  get "/" do
    blockchain.to_json
  end

  post "/new-block" do |env|
    data = env.params.json["data"].as(String)

    last_block = blockchain[blockchain.size - 1]
    new_block = Block.generate(last_block, data)

    if Block.is_valid?(new_block, last_block)
      blockchain << new_block

      puts "\n"
      p new_block
      puts "\n"
    end

    new_block.to_json
  end

  Kemal.run
end
