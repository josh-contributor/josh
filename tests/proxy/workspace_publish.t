  $ . ${TESTDIR}/setup_test_env.sh
  $ cd ${TESTTMP}


  $ git clone -q http://localhost:8001/real_repo.git
  warning: You appear to have cloned an empty repository.

  $ cd real_repo

  $ git status
  On branch master
  
  No commits yet
  
  nothing to commit (create/copy files and use "git add" to track)

  $ git checkout -b master
  Switched to a new branch 'master'

  $ mkdir ws
  $ cat > ws/workspace.josh <<EOF
  > a/b = :/sub2
  > EOF

  $ git add ws
  $ git commit -m "add workspace" 1> /dev/null

  $ mkdir sub2
  $ echo contents1 > sub2/file2
  $ git add sub2
  $ git commit -m "add file2" 1> /dev/null

  $ git log --graph --pretty=%s
  * add file2
  * add workspace


  $ git push
  To http://localhost:8001/real_repo.git
   * [new branch]      master -> master

  $ cd ${TESTTMP}

  $ git clone -q http://localhost:8002/real_repo.git:workspace=ws.git ws
  $ cd ws
  $ tree
  .
  |-- a
  |   `-- b
  |       `-- file2
  `-- workspace.josh
  
  2 directories, 2 files

  $ git log --graph --pretty=%s
  * add file2
  * add workspace

  $ git checkout master 1> /dev/null
  Already on 'master'

  $ mkdir -p c/subsub
  $ echo newfile_1_contents > c/subsub/newfile_1
  $ echo newfile_2_contents > a/b/newfile_2

  $ git add .

  $ git commit -m "add in filter" 1> /dev/null

  $ cat > workspace.josh <<EOF
  > a/b = :/sub2
  > c = :/sub1
  > EOF

  $ git add .
  $ git commit -m "publish" 1> /dev/null

  $ git push 2> /dev/null

  $ cd ${TESTTMP}/real_repo

  $ git pull --rebase 1> /dev/null
  From http://localhost:8001/real_repo
     7ac8997..842d478  master     -> origin/master

  $ git clean -ffdx 1> /dev/null

  $ tree
  .
  |-- sub1
  |   `-- subsub
  |       `-- newfile_1
  |-- sub2
  |   |-- file2
  |   `-- newfile_2
  `-- ws
      `-- workspace.josh
  
  4 directories, 4 files
  $ git log --graph --pretty=%s
  * publish
  * add in filter
  * add file2
  * add workspace

  $ git checkout HEAD~1 1> /dev/null
  Note: switching to 'HEAD~1'.
  
  You are in 'detached HEAD' state. You can look around, make experimental
  changes and commit them, and you can discard any commits you make in this
  state without impacting any branches by switching back to a branch.
  
  If you want to create a new branch to retain commits you create, you may
  do so (now or later) by using -c with the switch command. Example:
  
    git switch -c <new-branch-name>
  
  Or undo this operation with:
  
    git switch -
  
  Turn off this advice by setting config variable advice.detachedHead to false
  
  HEAD is now at 3eade03 add in filter
  $ tree
  .
  |-- sub2
  |   |-- file2
  |   `-- newfile_2
  `-- ws
      |-- c
      |   `-- subsub
      |       `-- newfile_1
      `-- workspace.josh
  
  4 directories, 4 files

  $ bash ${TESTDIR}/destroy_test_env.sh
  "real_repo.git" = [
      ':/sub2',
      ':/ws',
      ':workspace=ws',
  ]
  refs
  |-- heads
  |-- josh
  |   |-- filtered
  |   |   `-- real_repo.git
  |   |       |-- %3A%2Fsub2
  |   |       |   `-- HEAD
  |   |       |-- %3A%2Fws
  |   |       |   `-- HEAD
  |   |       `-- %3Aworkspace=ws
  |   |           `-- HEAD
  |   |-- rewrites
  |   |   `-- real_repo.git
  |   |       `-- 7bd92d97e96693ea7fd7eb5757b3580002889948
  |   |           `-- r_9db51080a4d148b32bd4c4e0b39eae8d0b3df763
  |   `-- upstream
  |       `-- real_repo.git
  |           |-- HEAD
  |           `-- refs
  |               `-- heads
  |                   `-- master
  |-- namespaces
  `-- tags
  
  16 directories, 6 files

$ cat ${TESTTMP}/josh-proxy.out | grep VIEW
