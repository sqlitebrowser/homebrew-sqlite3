class Sqlitefts5 < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org"
  url "https://sqlite.org/2023/sqlite-autoconf-3410200.tar.gz"
  version "3.41.2"
  sha256 "e98c100dd1da4e30fa460761dab7c0b91a50b785e167f8c57acc46514fae9499"

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
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_MATH_FUNCTIONS=1"
    ENV.append "CPPFLAGS", "-DSQLITE_MAX_ATTACHED=125"

    # Options that sound like they'll be useful
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_MEMORY_MANAGEMENT=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_SNAPSHOT=1"

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
