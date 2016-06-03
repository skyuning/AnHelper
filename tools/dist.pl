#! /usr/bin/perl

# author: Eden
# 打包前需要注意：
# 1. ./apktool下面给apktool和aapt建立相应系统的符号链接（ln -s aapt_<sys> aapt; ln -s apktool_<sys> apktool;）
# 2. 确认jarsigner和zipalign在PATH中，否则添加PATH或给它们也建立符号链接

use File::Basename;

if (@ARGV < 2) {
    die "Usage: dist.pl apk_file version [vendor_start vendor_en]";
}

my $apk_file = $ARGV[0];
my $version = $ARGV[1];
my $version_code = $version;
$version_code =~ s/\.//g;
print "apk filename is ", $apk_file, "\n";
print "Version is ", $version, "\n";
print "Version Code is ", $version_code, "\n\n";

# 解析apk文件名
my($fname, $dir, $ext) = fileparse($apk_file, '.apk');
$fname='SpringRainDoctor';

# 读vendors
my $vendor_start = $ARGV[2] * 1;
my $vendor_end = $ARGV[3] * 1;
if ($vendor_start != 0 && $vendor_end != 0) {
    @vendors = $vendor_start .. $vendor_end;
    for (@vendors) {
        $_ = $version_code.sprintf("%02s", $_);
    }
} else {
    open (VENDORS, "vendors.lst") or die "cannot find vendors file: vendors.lst";
    @vendors = <VENDORS>;
}

# 解apk包
print "Extract seed apk:\n";
$cmd = "./apktool/apktool d $apk_file -o ./res";
print $cmd, "\n\n";
`$cmd`;

# 备份AndroidManifest.xml
`cp ./res/AndroidManifest.xml .`;

`mkdir apks`;
print "\n";

# 循环打包
print "========== begin loop ==========\n";
for (@vendors) {
    chomp;

    # 写入vendor
    print 'Set vendor:', $_, "\n";
    $cmd = "echo $_ > ./res/assets/vendor.txt";
    print $cmd, "\n\n";
    `$cmd`;

    # 改permessable
    replace_pressmable($_);

    # 修改manifest
    modify_manifest($_);

    # 替换vendor logo
    replace_vendor_logo($_);

    # 重新组包
	print "Rebuild apk:\n";
	$cmd = "./apktool/apktool b -a ./apktool/aapt ./res/ -o ./temp.apk";
	print $cmd, "\n";
	`$cmd`;
	print "\n";

    # 重新签名
    # -storepass chunyu: keystore密码
    # -keypass chunyu: alias密码
    # -keysotre ./SpringRainKey: keystore
    # -signedjar ./apks/$dst_name: 输出签名过的apk包
    # ./tmp.apk: 未签名的apk包
    # chunyu: keystore中的alias名
    print "Sign:\n";
    my $dst_name_unzipaligned = "${fname}_${version}_${_}_unzipaligned.apk";
	$cmd = "jarsigner -verbose -storepass chunyu -keypass chunyu -keystore ./SpringRainKey -digestalg SHA1 -sigalg MD5withRSA -signedjar ./apks/${dst_name_unzipaligned} ./temp.apk chunyu";
    print $cmd, "\n\n";
	`$cmd`;

    # zipalign
    my $dst_name = "${fname}_${version}_${_}.apk";
    print "Zipalign:\n";
	$cmd = "zipalign -f 4 ./apks/${dst_name_unzipaligned} ./apks/$dst_name";
	print $cmd, "\n\n";
	`$cmd`;

	`rm ./apks/${dst_name_unzipaligned}`;

    print 'OK!', "\n\n";
	print "--------------------\n";
}
print "\n";

print 'Cleaning temp files...', "\n";
`rm -rf ./res`;
#`rm temp.apk`;
`rm ./AndroidManifest.xml`;
print 'Done', "\n";


sub replace_vendor_logo {
    my $vendor_num = $_[0];
    my $vendor_logo = "vendor_logo_${vendor_num}.png";
	print "Set vender logo: $vendor_logo\n";
    if (!-e $vendor_logo) {
        $vendor_logo = "vendor_logo_none.png";
        if (!-e $vendor_logo) {
            print "***********Error: Can not find vendor_logo_none.png!**********\n";
            exit();
        }
    }
    `rm ./res/res/drawable-xhdpi/vendor_logo.png`;
	my $cmd = "cp $vendor_logo ./res/res/drawable-xhdpi/vendor_logo.png";
	print $cmd, "\n\n";
	`$cmd`;
}

#   替换pressmable.txt
#   只有联通商店的包（vendor号为liantong）的pressmable内容为 00012243
#   其余vendor的包必须为 00012319
sub replace_pressmable {
    my $vendor = $_[0];
    if ($vendor eq 'liantong') {
        `echo 00012243 > ./res/assets/premessable.txt`;
    } else {
        `echo 00012319 > ./res/assets/premessable.txt`;
    }
}


#   给联通商店的包（vendor号为liantong）
#   必须在manifest中去掉 READ_SMS和WRITE_SMS两个权限
#   简单起见，在manifest中，权限必须写成如下的一行
#   <uses-permission android:name="android.permission.WRITE_SMS" />
#   否则报错
sub modify_manifest {
    my $vendor = $_[0];
    if ($vendor eq 'liantong') {
        open(MANIFEST, "./AndroidManifest.xml") or die("********Error: Cannot read AndroidManifest.xml");
        open(OUT, ">", "./res/AndroidManifest.xml") or die("********Error: Cannot write AndroidManifest.xml");
        foreach (<MANIFEST>) {
            if ($_ =~ /<uses-permission.*android\.permission\.(WRITE_SMS|READ_SMS)/) {
                next;
            } else {
                print OUT $_;
            }
        }
        close OUT;
        close MANIFEST;
    } else {
        `cp ./AndroidManifest.xml ./res`;
    }
}
