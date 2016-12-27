. "lib/stub.sh/stub.sh"

. "src/raspbian.sh" # Code Under Test

describe "raspbian"

  describe "raspbian_mount_image"

    it "should return 128 if the path to the Raspbian image isn't absolute"
      raspbian_mount_image "../relative/path/to/raspbian.img" "/mnt/rpi"

      assert equal "$?" 128
    end

    it "should return 129 if the path to the mount point isn't absolute"
      raspbian_mount_image "/path/to/raspbian.img" "../mnt/rpi"

      assert equal "$?" 129
    end

    # Herein we'll talk about the mount point rather than "the path to the mount
    # point".
    it "should return 130 if the mount point exists"
      raspbian_mount_image "/path/to/raspbian.img" "/tmp"

      assert equal "$?" 130
    end

    it "should mount the image"
      local mp_path="/tmp/$RANDOM"

      stub_and_echo kpartx "add map loop1p1\nadd map loop1p2"
      stub_and_eval mount "return 11"

      raspbian_mount_image "/path/to/raspbian.img" "$mp_path"

      assert equal "$?" 11 # It should return mount's exit status.
      assert test "[[ -e $mp_path ]]"

      stub_called_with mount "/dev/mapper/loop1p2" "$mp_path"
      assert equal "$?" 0

      restore mount
      restore kpartx

      rm -r "$mp_path"
    end

    it "should return 131 if the mount point can't be created"
      stub_and_eval mkdir "return 1"

      raspbian_mount_image "/path/to/raspbian.img" "/tmp/$RANDOM"

      assert equal "$?" 131

      restore mkdir
    end

  end

  describe "raspbian_unmount_image"

    it "should return 128 if the path to the Raspbian image isn't absolute"
      raspbian_unmount_image "../relative/path/to/raspbian.img" "/mnt/rpi"

      assert equal "$?" 128
    end

    it "should return 129 if the path to the mount point isn't absolute"
      raspbian_unmount_image "/path/to/raspbian.img" "../mnt/rpi"

      assert equal "$?" 129
    end

    it "should return 130 if the mount point doesn't exist"
      raspbian_unmount_image "/path/to/raspbian.img" "/tmp/$RANDOM"

      assert equal "$?" 130
    end

    it "should unmount the image"
      local mp_path="/tmp/$RANDOM"

      mkdir -p "$mp_path"

      stub_and_eval umount "return 0"
      stub_and_eval kpartx "return 11"

      raspbian_unmount_image "/path/to/raspbian.img" "$mp_path"

      # kpart'x exit status is ignored as it's not reliable.
      assert equal "$?" 0

      stub_called_with umount "$mp_path"
      assert equal "$?" 0

      assert test "[[ ! -e $mp_path ]]"

      stub_called_with kpartx "-d" "/path/to/raspbian.img"
      assert equal "$?" 0
    end

    it "should return 131 if the mount point can't be removed"
      stub "umount"
      stub_and_eval rm "return 1"
      stub kpartx

      raspbian_unmount_image "/path/to/raspbian.img" "/tmp"

      assert equal "$?" 131

      stub_called kpartx
      assert equal "$?" 1 # It doesn't continue processing.
    end

    it "should handle umount failing"
      stub_and_eval umount "return 11"
      stub rm

      raspbian_unmount_image "/path/to/raspbian.img" "/tmp"

      assert equal "$?" 11

      stub_called rm
      assert equal "$?" 1 # It doesn't continue processing.
    end

  end

end
