class Sqlitefts5 < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://sqlite.org/2019/sqlite-autoconf-3270200.tar.gz"
  version "3.27.2"
  sha256 "50c39e85ea28b5ecfdb3f9e860afe9ba606381e21836b2849efca6a0bfe6ef6e"
  revision 3

  bottle do
    root_url "https://nightlies.sqlitebrowser.org/homebrew_bottles"
    cellar :any
    #sha256 "f9588e984198c810d5d4188c8d5492eec1c4fdb8816be739627a8eb0bd2992dd" => :mojave
    sha256 "436401b01dd1ceafd7455df0b1c54ceaebf44c810d532b794875fb5eaa37b7fe" => :high_sierra
  end

  def install
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_COLUMN_METADATA=1"
    # Default value of MAX_VARIABLE_NUMBER is 999 which is too low for many
    # applications. Set to 250000 (Same value used in Debian and Ubuntu).
    ENV.append "CPPFLAGS", "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_RTREE=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_GEOPOLY=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS5=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_STAT4=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_JSON1=1"
    ENV.append "CPPFLAGS", "-DSQLITE_SOUNDEX=1"

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-dynamic-extensions
      --disable-readline
      --disable-editline
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    path = testpath/"school.sql"
    path.write <<~EOS
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
      select name from students order by age asc;
    EOS

    names = shell_output("#{bin}/sqlite3 < #{path}").strip.split("\n")
    assert_equal %w[Sue Tim Bob], names
  end
end
