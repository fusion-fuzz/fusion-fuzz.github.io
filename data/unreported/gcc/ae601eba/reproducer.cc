class InputStream
{
	public:
	virtual unsigned int readUint32 () = 0;
};
class Building
{
	__attribute__((transaction_safe)) Building (InputStream *stream);
	void load (InputStream *stream);
};
Building::Building (InputStream *stream)
{
	load(stream);
}
void Building::load (InputStream *stream)
{
	int j = (int)stream->readUint32 ();
}
