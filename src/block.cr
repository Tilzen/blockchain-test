module Block
  extend self

  def calculate_hash(block)
    text = "
      #{block[:index]}
      #{block[:timestamp]}
      #{block[:data]}
      #{block[:prev_hash]}
    "
    hash_sha256 = OpenSSL::Digest.new("SHA256")
    hash_sha256.update(text)
    hash_sha256.to_s
  end

  def create(index, timestamp, data, prev_hash)
    block = {
      index: index,
      timestamp: timestamp,
      data: data,
      prev_hash: prev_hash,
      difficulty: self.difficulty,
      nonce: ""
    }
    block.merge({ hash: self.calculate_hash(block) })
  end

  def difficulty
    1
  end

  def generate(last_block, data)
    new_block = self.create(
      last_block[:index] + 1,
      Time.utc.to_s,
      data,
      last_block[:hash]
    )

    i = 0

    loop do
      hex = i.to_s(16)
      new_block = new_block.merge({ nonce: hex })

      calculated_hash = self.calculate_hash(new_block)
      if !self.is_hash_valid?(calculated_hash, new_block[:difficulty])
        puts "\nMining: trying another nonce... #{hex}\nhash: #{calculated_hash}"
        i += 1
        next
      else
        puts "\nMining complete! Nonce for this block is #{new_block[:nonce]}"
        new_block = new_block.merge({ hash: calculated_hash })
        break
      end
    end

    new_block
  end

  def is_hash_valid?(hash, difficulty)
    prefix = "0" * difficulty
    hash.starts_with?(prefix)
  end

  def is_valid?(new_block, old_block)
    if new_block[:index] + 1 != old_block[:index]
      return false
    elsif old_block[:hash] != new_block[:prev_hash]
      return false
    elsif self.calculate_hash(new_block) != new_block[:hash]
      return false
    end

    true
  end
end
