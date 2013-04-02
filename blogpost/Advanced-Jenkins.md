Jenkins is your CI butler, and any reader of [P.G. Wodehouse](http://en.wikipedia.org/wiki/P._G._Wodehouse) or viewer of British period drama knows that treating your host's butler well is the key to an enjoyable visit. Likewise, giving Jenkins a bit of extra care and attention can greatly enhance your team's experience with CI and make the entire team more productive.

When putting the following configs together I had to wade through a great many sources, so I thought it would be useful to put everything I've learned together in one document. I'm going to walk you through creating a fully instrumented Jenkins setup from scratch for iOS and Mac OS X projects. It will monitor errors, static analyser results, unit tests and code coverage for you, mail you when anything goes wrong, and present the results graphically, like this:

<img src="http://www.sailmaker.co.uk/blog/wp-content/uploads/2013/04/AdvancedJenkinsJenkins-sample-output.png" alt="Sample Jenkins output" title="Jenkins-sample-output.png" border="0" width="506" height="903" />

## GitHub archive
An archive of a sample project (based on Apple sample code) together with sample Jenkins configs is available at [https://github.com/richardbuckle/AdvancedJenkins](https://github.com/richardbuckle/AdvancedJenkins).

## <a id="Contents"></a>Contents

[Installing Jenkins itself](#Installing-Jenkins-itself)

[Installing ancillary tools](#Installing-ancillary-tools)

[Installing Jenkins plug-ins](#Installing-Jenkins-plug-ins)

[Final Jenkins configuration](#Final-Jenkins-configuration)

[Job configuration](#Job-configuration)

[Conclusion](#Conclusion)

## <a id="Installing-Jenkins-itself"></a>Installing Jenkins itself

I'm going to assume that you'll be running Jenkins as a full Mac OS X user in a windowed session, on a secured box, perhaps a Mac Mini, and that said user already has Xcode 4.6.1 installed together with all the provisioning and code-signing set up for any TestFlight, HockeyApp, or other distribution that you might need.

I am not going to cover running Jenkins as a daemon, as that causes so many woes with the Xcode toolchain, code-signing etc, that I don't recommend it. 

I'm also going to recommend installing Jenkins via Homebrew, to avoid some nonsense in Jenkins' own installer whereby it puts itself in `/Users/Shared/`. You really don't want that.

### Install Homebrew
Homebrew is [here](http://mxcl.github.com/homebrew/).

For a machine-wide installation: `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"`

More fine-tuned installation instructions are [here](https://github.com/mxcl/homebrew/wiki/Installation).

Personally I wanted Homebrew confined entirely to my account for a bit more security, so I chose to `git clone` it from [https://github.com/mxcl/homebrew/]() to `~/homebrew` and manually added `$HOME/homebrew/bin` to my `$PATH` via my `~/.bash_profile`. Your preferences may vary.

### Install Jenkins
This one's easy: `brew install jenkins`

You can start and stop Jenkins with:

    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.jenkins.plist
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.jenkins.plist

You might want to make shell aliases for those.

If you have installed Jenkins via other means, then the plist may be elsewhere and/or have a different name. Look in:

     ~/Library/LaunchAgents     Per-user agents provided by the user.
     /Library/LaunchAgents      Per-user agents provided by the administrator.
     /Library/LaunchDaemons     System wide daemons provided by the administrator.

### Test the server

You should now be able to connect to your Jenkins sever at [http://localhost:8080]() on the local machine. Try the start and stop commands given above and verify that they send the server up and down as expected.

Don't bother configuring any projects just yet: we'll come to that.

### First run

The first time you run an Xcode job in Jenkins, you will probably need to be VNC'd into the server so that you can click "Always Allow" when the process asks for confirmation of keychain access. This can only be done via the GUI, alas, but once done you should never see it again.

### Secure your Jenkins installation
**This requires consideration of your specific setup** and a full discussion is out of scope for this document.

The level of security that you'll need will depend upon whether the server is accessible LAN-only, VPN-only, or public Internet. This is entirely your call. 

I would go with LAN-only if possible, falling back to VPN into a strictly controlled subnet of your LAN if you need to give access to outsiders. Setting up a VPN is a bore, but it is the best option: both for access control and for preventing snooping and man-in-the-middle attacks when your clients inevitably use untrusted public WiFI etc.

**NEVER run your Jenkins server on a laptop that roams on public WiFi**: you're wide open to man-in-the-middle attacks if you do that!

Googling [Jenkins Security](https://www.google.co.uk/search?q=jenkins+security) will give you a lot of good advice.

### Put your Jenkins jobs dir under version control
All of your Jenkins job specifications are in its `jobs` subdirectory. I *highly* recommend you put it under version control immediately and also push to a separately hosted repo that is inaccessible to anyone who can VPN in, etc.

Not only will this give you the usual benefits of tracking and diffing config changes, and making changes with the confidence that you can revert if you mess up, but it will also give you an easy migration to a new server or an additional slave machine.

Tip: if you ever change anything in the `jobs` dir outside the web UI, go to Dashboard > Manage Jenkins and click "Reload Configuration from Disk" to force Jenkins to see your changes.

[Back to Contents](#Contents)

## <a id="Installing-ancillary-tools"></a>Installing ancillary tools
Phew, that's over. Next I shall walk you through adding the ancillary stuff that will make your Jenkins installation vastly more useful.

I'm going to put these in `usr/local/bin`. If you prefer to put them elsewhere then modify what follows accordingly.

### OCUnit2JUnit
This is a very nifty script that converts OCUnit test results into the JUnit format that Jenkins plug-ins can parse and display.

Clone [https://github.com/ciryon/OCUnit2JUnit](https://github.com/ciryon/OCUnit2JUnit) and install it in `/usr/local/bin/`:

	cd ~
	git clone https://github.com/ciryon/OCUnit2JUnit
	sudo cp ./OCUnit2JUnit/bin/ocunit2junit /usr/local/bin
	sudo chown root:wheel /usr/local/bin/ocunit2junit
	sudo chmod 755 /usr/local/bin/ocunit2junit
	
Optionally, cleanup the Git repo:

	cd ~
	rm -rf ./OCUnit2JUnit/

To use OCUnit2JUnit, pipe the output of any `xcodebuild` command that emits OCUnit tests results to it, e.g.:

    xcodebuild -scheme "Logic Tests" test ... | /usr/local/bin/ocunit2junit

Below I'll describe adding the post-build action "Publish JUnit test result report" to publish the test results.

### gcovr
I am glad to say that [gcovr](https://software.sandia.gov/trac/fast/wiki/gcovr) is no longer a heavyweight install as I previously found. At the time of writing, the latest version is available for immediate download [from SVN](https://software.sandia.gov/svn/public/fast/gcovr) or you can just look at [the home page](https://software.sandia.gov/trac/fast/wiki/gcovr) and pick a download option.

Put it into `/usr/local/bin` as usual. From the download path:

	sudo cp ./gcovr /usr/local/bin
	sudo chown root:wheel /usr/local/bin/gcovr
	sudo chmod 755 /usr/local/bin/gcovr

### Clang static analyzer
Surprisingly, the Xcode command-line tools don't allow first-class reporting of Clang static analyzer errors. Until Apple fixes this, we need to install `scan-build` directly.

[scan-build's page](http://clang-analyzer.llvm.org/scan-build.html) is worth a read.

Go to [the Clang static analyzer's home page](http://clang-analyzer.llvm.org/index.html) and grab the latest tarball. At the time of writing, it is 2.7.2. Unpack it to get a folder, say, `checker-272`.

	cd /path/containing/it
	sudo mv checker-272 /usr/local/bin/
	sudo chown -R root:wheel /usr/local/bin/checker-272
	sudo chmod -R 755 /usr/local/bin/checker-272
	
Next, create a symbolic link for it. That way you won't need to update all your Jenkins jobs when you download a new drop of `scan-build`, but can simply revise the symbolic link:

	sudo ln -s /usr/local/bin/checker-272 /usr/local/bin/checker-current

Now we can run an independent Clang static analyzer and report results regardless of any attempts by team-mates to turn it off in project settings, etc.

### ios-sim
Until Apple get their act together and enable unit testing in the iOS Simulator from the command line, this tool plugs the gap.

To get `ios-sim` from Homebrew, copy it to `/usr/local/bin` and ensure that it has ownership `root:wheel` and flags `-rwxr-xr-x` (octal 755), we do this:

	brew install ios-sim 
	sudo cp $(brew list ios-sim | grep bin/ios-sim) /usr/local/bin
	sudo chown -R root:wheel /usr/local/bin/ios-sim
	sudo chmod -R 755 /usr/local/bin/ios-sim

[Back to Contents](#Contents)


## <a id="Installing-Jenkins-plug-ins"></a>Installing Jenkins plug-ins
These are what I use:

### Essential plug-ins
I think everyone will need these, most of which come with the default installation:

-   [Token Macro Plugin](http://wiki.jenkins-ci.org/display/JENKINS/Token+Macro+Plugin)
-   [Log Parser Plugin](http://wiki.hudson-ci.org/display/HUDSON/Log+Parser+Plugin)
-   [Jenkins Mailer Plugin](http://wiki.jenkins-ci.org/display/JENKINS/Mailer)
-   [Warnings Plug-in](http://wiki.jenkins-ci.org/x/G4CGAQ)

### Git-related plug-ins
Most of these come with the default installation. Might as well have them installed up front and have done with it. Be sure to have `git client plugin` >= 1.0.5 as 1.0.4 had severe issues (promptly fixed).

-   [Jenkins Git client plugin](http://wiki.jenkins-ci.org/display/JENKINS/Git+Client+Plugin)
-   [Jenkins Git plugin](http://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin)
-   [GitHub API Plugin](https://wiki.jenkins-ci.org/display/JENKINS/GitHub+API+Plugin)
-   [GitHub plugin](http://wiki.jenkins-ci.org/display/JENKINS/Github+Plugin)

### Concurrency plug-ins
-   [Locks and Latches plugin](https://wiki.jenkins-ci.org/display/JENKINS/Locks+and+Latches+plugin) We use this as noted below to serialize builds that invoke `ios-sim`.

### Social plug-ins
-   [Jenkins Gravatar plugin](http://wiki.jenkins-ci.org/display/JENKINS/Gravatar+Plugin) -- I think it helps accountability if everyone shows their face against each commit.

### Static analysis plug-ins
-   [Static Analysis Utilities](http://wiki.jenkins-ci.org/x/CwDgAQ)
-   [Clang Scan-Build Plugin](http://wiki.jenkins-ci.org/display/JENKINS/Clang+Scan-Build+Plugin) -- its input side is a bit limited, so I tend to drop to shell script for that and just use it to show the output: see below.

### TDD/Code coverage plug-ins
-   [Jenkins Cobertura Plugin](http://wiki.jenkins-ci.org/display/JENKINS/Cobertura+Plugin)

### Deployment plug-ins
-   [Hockeyapp Plugin](http://wiki.jenkins-ci.org/display/JENKINS/Hockeyapp+Plugin)
-   [Testflight Plugin](http://wiki.jenkins-ci.org/display/JENKINS/Testflight+Plugin)

### Not recommended
I wish I could recommend the [XCode integration](https://wiki.jenkins-ci.org/display/JENKINS/Xcode+Plugin) plug-in, but I really can't. It has too many [known issues](https://wiki.jenkins-ci.org/display/JENKINS/Xcode+Plugin#XcodePlugin-Knownissues), particularly that it [misparses quoted parameters containing white space](https://issues.jenkins-ci.org/browse/JENKINS-12800), an issue that has been open for over a year. I've also found that it has trouble parsing log output, often giving spurious fatal errors such as "[FATAL: Log statements out of sync](http://stackoverflow.com/questions/14682694/jenkins-ios-job-broken-because-fatal-log-statements-out-of-sync-current-test)".

If any reader has the time and knowledge to fix this plug-in, I'm sure the entire community would be very grateful. Meanwhile, I've dropped back to shell script using the techniques shown in WWDC 2012 vid 404. You don't need to write very much shell script and it's vastly more flexible anyhow.

[Back to Contents](#Contents)

## <a id="Final-Jenkins-configuration"></a>Final Jenkins configuration
Next we need to do a bit of system-wide configuration of some of the plug-ins that we've added. From the Jenkins home page, click "Manage Jenkins", then "Configure System".

### Locks
Find the section called "Locks":

<img src="http://www.sailmaker.co.uk/blog/wp-content/uploads/2013/04/AdvancedJenkinsLocks-default.png" alt="Locks section defaults" title="Locks-default.png" border="0" width="715" height="107" />

Click "Add" and set the name to, say, "iOS-sim".

<img src="http://www.sailmaker.co.uk/blog/wp-content/uploads/2013/04/AdvancedJenkinsLocks-with-ios-sim.png" alt="Locks section with iOS-sim added" title="Locks-with-ios-sim.png" border="0" width="711" height="111" />

### Configuring Clang static analyzer
Click the button "Clang Static Analyzer installations". 

Click "Add Clang Static Analyzer" and set the name to, say, `Clang-current` and the "Installation directory" to `/usr/local/bin/checker-current`. This is the symlink we created above to avoid having to revise this config when we update scan-build.

<img src="http://www.sailmaker.co.uk/blog/wp-content/uploads/2013/04/AdvancedJenkinsconfigure-clang-analyzer.png" alt="Configuring Clang static analyzer" title="configure-clang-analyzer.png" border="0" width="830" height="164" />

### Any other business
You will probably want to fill out the sections titled "Jenkins Location" and "E-mail Notification" here as well. 

When you're done, click the "Save" button at the very bottom of the page.

[Back to Contents](#Contents)

## <a id="Job-configuration"></a>Job configuration

At this point I recommend you grab my sample configs from [my GitHub repo](https://github.com/richardbuckle/AdvancedJenkins) so you can follow along. Move the two configs from the jobs directory in the repo into Jenkins' jobs directory, go to Dashboard > Manage Jenkins and click "Reload Configuration from Disk". Both configs should build "out of the box" but you may first want to visit the config page for each one and enter your email address under "E-mail Notification" at the very bottom.

Don't be concerned if Jenkins doesn't show the graphs right away: all the graphing tools need at least two successful builds to show a graph. Just kick off another build and the graphs should show up.

I'll start by going through the Logic Tests config, as it is the simpler of the two, then point out the differences in the Application tests config and a change we need to make to the XCode project to get it to use ios-sim when we want. 

The Git and Build Triggers sections are unremarkable so I will not discuss them.

### Shell script walk-through

To select the version of Xcode we want, we set `DEVELOPER_DIR` rather than using `xcode-select`. This has the twin advantages of only affecting the job in hand and not requiring root privileges:

    # set the desired version of Xcode
    set DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
    export DEVELOPER_DIR

Next, for safety, we do a default clean of the workspace. Note that `${WORKSPACE}` refers to the Jenkins workspace, not the Xcode one. We will still be cleaning each target or scheme as we build it, as I've found that in some cases the default clean doesn't cover everything.

    # do a default clean
    cd "${WORKSPACE}"
    xcodebuild clean

Next we run the static analyzer on the main code base (i.e. not the unit tests, but the code that they are testing), sending the output to `./clangScanBuildReports`. We could have used the Clang Scan-Build plug-in's build step for this, but shell script gives us more flexibility:

    # run the static analyzer on the main code base
    /usr/local/bin/checker-current/scan-build -k -v -v --keep-empty -o ./clangScanBuildReports xcodebuild -scheme Calculator-iOS -configuration Debug ONLY_ACTIVE_ARCH=NO clean build

Note how we used the symlink `/usr/local/bin/checker-current` that we created above so that we won't need to revise this config when we update our version of scan-build.

We are going to tell Xcode to put its intermediate output in `"${WORKSPACE}"/tmp/objs` rather than its default path of `~/Library/.../DerivedData/...` so that `gcovr` will be able to find it. First we delete any such pre-existing directory:

    # delete our custom intermediates directory
    rm -rf "${WORKSPACE}"/tmp/objs

To redirect Xcode's intermediate output, we set `OBJROOT`. Note that this has to be done in the parameters to `xcodebuild` — setting and exporting an environment variable won't work. As mentioned above, we pipe the output to `ocunit2junit` so that Jenkins can display unit test results:

    # build the test target using our custom intermediates directory
    # and pipe the output to ocunit2junit
    xcodebuild -target Calculator-iOS_LogicTests -configuration Debug -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO TEST_AFTER_BUILD=YES OBJROOT="${WORKSPACE}"/tmp/objs clean build | /usr/local/bin/ocunit2junit

Finally we call `gcovr` to generate the coverage report, outputting to `./coverage.xml`. You may wish to tune the `--exclude=` parameter (note that it is one big regex, not a Unix-style glob, and needs to be in single quotes):

    # generate the coverage report
    cd "${WORKSPACE}"
    /usr/local/bin/gcovr --root="${WORKSPACE}" --exclude='(.*./Developer/SDKs/.*)|(.*Tests\.m)' -x > ./coverage.xml

### Post-build Actions

#### Compiler warnings

Add the "Scan for compiler warnings" post-build step and configure it to use the "Apple LLVM Compiler (Clang) parser like this:

<img src="http://www.sailmaker.co.uk/blog/wp-content/uploads/2013/04/AdvancedJenkinspost-build-compiler-warnings.png" alt="Scan for compiler warnings" title="post-build-compiler-warnings.png" border="0" width="694" height="318" />

It shouldn't need any further configuration.

#### Scan-build results

Add the "Publish Clang Scan-Build Results" post-build step:

<img src="http://www.sailmaker.co.uk/blog/wp-content/uploads/2013/04/AdvancedJenkinspost-build-scan-build.png" alt="Publish Clang Scan-Build Results" title="post-build-scan-build.png" border="0" width="437" height="110" />

Optionally, set a threshold past which the build will be marked as unstable.

#### Coverage report

Add the "Publish Cobertura Coverage Report" post-build step, giving it the report pattern `coverage.xml`. Optionally, configure the detail to your liking:

<img src="http://www.sailmaker.co.uk/blog/wp-content/uploads/2013/04/AdvancedJenkinspost-build-cobertura.png" alt="Publish Cobertura Coverage Report" title="post-build-cobertura.png" border="0" width="698" height="710" />

#### Unit test report

Add the "Publish JUnit test result report" post-build step, giving it the XML specifier `test-reports/*.xml`:

<img src="http://www.sailmaker.co.uk/blog/wp-content/uploads/2013/04/AdvancedJenkinspost-build-junit-test.png" alt="Publish JUnit test result report" title="post-build-junit-test.png" border="0" width="699" height="163" />

#### E-mail Notification

Add the E-mail Notification post-build step if it isn't already there and configure it to your liking. I'd advise keeping "Send separate e-mails to individuals who broke the build" on!

### Differences for the Application tests config

That's it for the Logic tests config. The application tests config differs slightly in that we need to get it to use ios-sim and we need to use a concurrency lock to stop two jobs trying to use ios-sim at the same time.

#### Concurrency lock

In the "Build Environment" step, check "Locks" and select the "iOS-sim" lock:

<img src="http://www.sailmaker.co.uk/blog/wp-content/uploads/2013/04/AdvancedJenkinsLocks-set-on-ios-sim.png" alt="iOS-sim lock" title="Locks-set-on-ios-sim.png" border="0" width="656" height="118" />

#### Shell script

The only substantive difference is that we add the parameter `WANT_IOS_SIM=YES` to the `xcodebuild` command:

    xcodebuild -target iOS_Calc_ApplicationTests -configuration Debug -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO TEST_AFTER_BUILD=YES GCC_TREAT_WARNINGS_AS_ERRORS=YES WANT_IOS_SIM=YES OBJROOT="${WORKSPACE}"/tmp/objs build | /usr/local/bin/ocunit2junit

This is an environment variable of our own devising which we have customised the Xcode project to notice as described next.

Other than that this Jenkins config differs only in the scheme/target that we tell it to build.

#### Fixing the Xcode project for app testing

While Xcode 4.6.1's Simulator does in fact support app testing from the command line, Apple have neglected to revise Xcode's internal scripts to reflect that. This is why we installed `ios-sim` above.

This code assumes that `ios-sim` is in `/usr/local/bin`. If you put it elsewhere, adjust the script accordingly (as a matter of security, I always specify absolute paths to my binary files, and don't trust $PATH).

Open the project in Xcode, select the project then the target `iOS_Calc_ApplicationTests`, select the "Build Phases" tab, and expand the "Run Script" phase. You will see this:

	# Run the unit tests in this test bundle.
	if [ -z "${WANT_IOS_SIM}" ]
	then
	#   Running under Xcode
	    "${DEVELOPER_TOOLS_DIR}/RunUnitTests"
	else
	#   Running under xcodebuild, so use ios-sim installed from Homebrew into /usr/local/bin/ios-sim
	    killall -m -KILL "iPhone Simulator" || true
	    our_test_bundle_path=$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.$WRAPPER_EXTENSION
	    our_env=("--setenv" "DYLD_INSERT_LIBRARIES=/../../Library/PrivateFrameworks/IDEBundleInjection.framework/IDEBundleInjection")
	    our_env=("${our_env[@]}" "--setenv" "XCInjectBundle=${our_test_bundle_path}")
	    our_env=("${our_env[@]}" "--setenv" "XCInjectBundleInto=${TEST_HOST}")
	    our_app_location="$(dirname "${TEST_HOST}")"
	    /usr/local/bin/ios-sim launch "${our_app_location}" "${our_env[@]}" --args -SenTest All "${our_test_bundle_path}" --exit
	    killall -m -KILL "iPhone Simulator" || true
	    exit 0
	fi

What this means is that if the environment variable `WANT_IOS_SIM` is not set, we call `${DEVELOPER_TOOLS_DIR}/RunUnitTests` as per usual. This means that you still get the usual behaviour when working in Xcode and in particular you will be able to run application tests on iOS devices in the usual way.

If on the other hand `WANT_IOS_SIM` is set, we kill any existing iPhone Simulator process, set up variables for our test bundle path etc, call `ios-sim` manually, and then kill the simulator when we're done. Slimy but effective.

You may also come across advice to amend `.../Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Tools/RunPlatformUnitTests` along similar lines. While this works, I advise against it as it will be fragile against future Xcode updates. With the above fix, simply don't set `WANT_IOS_SIM` and you will always get Apple's intended behaviour.

[Back to Contents](#Contents)

## <a id="Conclusion"></a>Conclusion

Wow. That has been quite a journey.

Now that you've got a running config, play around. Break a unit test, or introduce a static analyzer warning and see Jenkins report it. Drill down into the unit test and coverage reports to get a sense of what's available.

I hope that this article hase been useful and will help you get a lot more out of Jenkins! Comments, questions and errata can be sent to @RichardBuckle on [Twitter](https://twitter.com/RichardBuckle) or [App.net](https://alpha.app.net/richardbuckle).

Shameless plug: I am available for contract iOS and Mac development. If you are interested in hiring me, please see [http://www.sailmaker.co.uk/]().

[Back to Contents](#Contents)