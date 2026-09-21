# WorkManager 2.7.0 uses Room 2.2.5 to construct this class via Class.newInstance().
# Room's consumer rule keeps the class but not its constructor under strict R8
# full mode. Retain only the reflected entry point; keep shrinking enabled.
-keep class androidx.work.impl.WorkDatabase_Impl {
    public <init>();
}
