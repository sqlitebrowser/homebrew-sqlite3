class Sqlitefts5 < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://sqlite.org/2019/sqlite-autoconf-3270100.tar.gz"
  version "3.27.1"
  sha256 "54a92b8ff73ff6181f89b9b0c08949119b99e8cccef93dbef90e852a8b10f4f8"
  revision 1

  bottle do
    root_url "https://nightlies.sqlitebrowser.org/jc_testing"
    cellar :any
    #sha256 "eaef16904d5b1ce29dee315b04ff8739dc35f6e2268684eb9add4609e7226042" => :sierra
    #sha256 "eaef16904d5b1ce29dee315b04ff8739dc35f6e2268684eb9add4609e7226042" => :high_sierra
    sha256 "6d0b15dcb76896ee7403c989496e553a1cc7b90f934233b0950ce6187397015e" => :mojave
  end

  def install
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_COLUMN_METADATA=1"
    # Default value of MAX_VARIABLE_NUMBER is 999 which is too low for many
    # applications. Set to 250000 (Same value used in Debian and Ubuntu).
    ENV.append "CPPFLAGS", "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_RTREE=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS5=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_JSON1=1"

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
