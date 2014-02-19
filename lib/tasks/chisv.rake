IMPORT_URL = 'http://chi-sv.org/admin/export.php?k=3ReEwluKNjPPUuVA&t=%s'
#IMPORT_URL = 'http://hci.rwth-aachen.de/~jon/chisv-import/%s.csv'

namespace :chisv do
  desc 'Perform all chisv tasks'
  task :all => [:import, :fix_tshirts, :fix_chi08]
  
  desc 'Import all data from old website'
  task :import => :environment do
    importer = Importer.new IMPORT_URL
    importer.go
  end

  desc 'Wipe out the database'
  task :wipe => :environment do
    Importer.wipe
  end

  desc 'Fix invalid tshirt entries issue'
  task :fix_tshirts => :environment do
    Importer.fix_tshirts
  end
  
  desc 'Make adjustments for CHi 2008'
  task :fix_chi08 => :environment do
    Importer.fix_chi08
  end
end
