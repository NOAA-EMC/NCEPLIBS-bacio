  function test_wryte() result(err_stat)
!
        implicit none
!
       integer :: err_stat
!
       integer,parameter :: strl=40
       character(strl) arr,arr1
       character(255) cin
       integer ios,flunit
       integer iskip,iread,nread
!
!--- indicate successful error status
       err_stat = 0
    

       flunit=99
       cin='data_wryte'
!
       arr='this is my test string file using bacio.'
      call baopenwt(flunit,trim(cin),ios)
      call WRYTE(flunit,strl,arr)
       call baclose(flunit,ios)

!--- read file
      call baopenr(flunit,trim(cin),ios)
      iskip=0
      iread=strl
      call baread(flunit,iskip,iread,nread,arr1)
      call baclose(flunit,ios)
      
      if(trim(arr1)/=trim(arr) ) then
          print *,'BACIO: wrong with wryte'
          err_stat = 1; return
      endif
!
       print *,'BACIO unit test: test_wryte ends normally'

  end function test_wryte
