class Sqlcipherdb4s < Formula
  desc "SQLite extension providing 256-bit AES encryption"
  homepage "https://www.zetetic.net/sqlcipher/"
  url "https://github.com/sqlcipher/sqlcipher/archive/v4.5.2.tar.gz"
  sha256 "6925f012deb5582e39761a7d4816883cc15b41851a8e70b447c223b8ef406e2a"
  head "https://github.com/sqlcipher/sqlcipher.git"

  bottle do
    root_url "https://nightlies.sqlitebrowser.org/homebrew_bottles"
    sha256 cellar: :any, arm64_monterey: "56ee8c01158e56af1fddf2bd92c1c69711f0b082b2b8028473b5cf8033cfee3d"
    sha256 cellar: :any, catalina: "1ac0cab10dcc87211c1c67868a788b89f84dd8acf59e12a012c8a75e28c60a0f"
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
    args << "CFLAGS=-DSQLITE_HAS_CODEC -DSQLITE_ENABLE_STAT4 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_GEOPOLY -DSQLITE_ENABLE_RTREE -DSQLITE_SOUNDEX -DSQLITE_ENABLE_MEMORY_MANAGEMENT=1 -DSQLITE_ENABLE_SNAPSHOT=1"

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
