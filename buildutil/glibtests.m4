dnl GLIB_TESTS
dnl NOTE: this file has been modified from upstream glib; see
dnl https://github.com/ostreedev/ostree/pull/837

AC_DEFUN([GLIB_TESTS],
[
  AC_ARG_ENABLE(installed-tests,
                AS_HELP_STRING([--enable-installed-tests],
                               [Enable installation of some test cases]),
                [enable_installed_tests=${enableval};
                 case ${enableval} in
                  yes) ENABLE_INSTALLED_TESTS="1"  ;;
                  exclusive) ENABLE_INSTALLED_TESTS="1"; ENABLE_INSTALLED_TESTS_EXCLUSIVE=1 ;;
                  no)  ENABLE_INSTALLED_TESTS="" ;;
                  *) AC_MSG_ERROR([bad value ${enableval} for --enable-installed-tests]) ;;
                 esac])
  AM_CONDITIONAL([ENABLE_INSTALLED_TESTS], test "$ENABLE_INSTALLED_TESTS" = "1")
  AM_CONDITIONAL([ENABLE_INSTALLED_TESTS_EXCLUSIVE], test "$ENABLE_INSTALLED_TESTS_EXCLUSIVE" = "1")
  AC_ARG_ENABLE(always-build-tests,
                AS_HELP_STRING([--enable-always-build-tests],
                               [Enable always building tests during 'make all']),
                [case ${enableval} in
                  yes) ENABLE_ALWAYS_BUILD_TESTS="1"  ;;
                  no)  ENABLE_ALWAYS_BUILD_TESTS="" ;;
                  *) AC_MSG_ERROR([bad value ${enableval} for --enable-always-build-tests]) ;;
                 esac])
  AM_CONDITIONAL([ENABLE_ALWAYS_BUILD_TESTS], test "$ENABLE_ALWAYS_BUILD_TESTS" = "1")
  if test "$ENABLE_INSTALLED_TESTS" = "1"; then
    AC_SUBST(installed_test_metadir, [${datadir}/installed-tests/]AC_PACKAGE_NAME)
    AC_SUBST(installed_testdir, [${libexecdir}/installed-tests/]AC_PACKAGE_NAME)
  fi
])
