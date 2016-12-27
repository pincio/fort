describe "path"

  . "src/path.sh"

  describe "path_is_absolute"

    it "should return 0 if the path is absolute"
      path_is_absolute "/foo"

      assert equal "$?" 0
    end

    it "should return 1 if the path is relative"
      path_is_absolute "./foo"

      assert equal "$?" 1
    end

  end

end
