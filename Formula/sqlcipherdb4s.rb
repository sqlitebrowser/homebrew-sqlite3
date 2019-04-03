class Sqlcipherdb4s < Formula
  desc "SQLite extension providing 256-bit AES encryption"
  homepage "https://www.zetetic.net/sqlcipher/"
  url "https://github.com/sqlcipher/sqlcipher/archive/v4.1.0.tar.gz"
  sha256 "65144ca3ba4c0f9cd4bae8c20bb42f2b84424bf29d1ebcf04c44a728903b1faa"
  head "https://github.com/sqlcipher/sqlcipher.git"

  bottle do
    root_url "https://nightlies.sqlitebrowser.org/homebrew_bottles"
    cellar :any
    #sha256 "b017765022c359fd2412c9b8ed113ce58d75e50e6d1d3b3fab2e25daccd46a66" => :mojave
    sha256 "7a846731eb5b7c4149ab464355e3fd5f015c0777afae7314451e4fe882269548" => :high_sierra
  end

  depends_on "openssl"

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-tempstore=yes
      --with-crypto-lib=#{Formula["openssl"].opt_prefix}
      --enable-load-extension
      --disable-tcl
    ]

    # Build with full-text search enabled
    args << "CFLAGS=-DSQLITE_HAS_CODEC -DSQLITE_ENABLE_STAT4 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_GEOPOLY -DSQLITE_ENABLE_RTREE"

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    path = testpath/"school.sql"
    path.write <<~EOS
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', json_extract('{"age": 13}', '$.age'));
      select name from students order by age asc;
    EOS

    names = shell_output("#{bin}/sqlcipher < #{path}").strip.split("\n")
    assert_equal %w[Sue Tim Bob], names
  end
end
